$ErrorActionPreference = 'Stop'

$repoName = 'laser-self-mixing-vascular-portfolio'
$credentialRequest = "protocol=https`nhost=github.com`n`n"
$credentialLines = $credentialRequest | git credential fill
$credential = @{}
foreach ($line in $credentialLines) {
    if ($line -match '^([^=]+)=(.*)$') { $credential[$matches[1]] = $matches[2] }
}
if (-not $credential.ContainsKey('password')) { throw 'GitHub credential is unavailable.' }

$headers = @{
    Authorization = "Bearer $($credential['password'])"
    Accept = 'application/vnd.github+json'
    'X-GitHub-Api-Version' = '2022-11-28'
    'User-Agent' = 'Codex-Portfolio-Publisher'
}
$account = Invoke-RestMethod -Uri 'https://api.github.com/user' -Headers $headers
$owner = $account.login
$apiRoot = "https://api.github.com/repos/$owner/$repoName"

function Invoke-GitHubJson {
    param([string]$Method, [string]$Uri, $Body)
    $json = $Body | ConvertTo-Json -Depth 10 -Compress
    Invoke-RestMethod -Method $Method -Uri $Uri -Headers $headers -Body $json -ContentType 'application/json'
}

function Publish-Branch {
    param(
        [string]$Branch,
        [string]$Root,
        [string[]]$Files,
        [switch]$StripRoot
    )
    $treeEntries = @()
    foreach ($file in $Files) {
        $absolute = (Resolve-Path $file).Path
        $bytes = [IO.File]::ReadAllBytes($absolute)
        $blob = Invoke-GitHubJson -Method Post -Uri "$apiRoot/git/blobs" -Body @{
            content = [Convert]::ToBase64String($bytes)
            encoding = 'base64'
        }
        $relative = [IO.Path]::GetRelativePath((Resolve-Path $Root).Path, $absolute).Replace('\','/')
        $treeEntries += @{ path = $relative; mode = '100644'; type = 'blob'; sha = $blob.sha }
    }
    $tree = Invoke-GitHubJson -Method Post -Uri "$apiRoot/git/trees" -Body @{ tree = $treeEntries }

    $parents = @()
    $existingRef = $null
    try {
        $existingRef = Invoke-RestMethod -Uri "$apiRoot/git/ref/heads/$Branch" -Headers $headers
        $parents = @($existingRef.object.sha)
    } catch {
        if ($_.Exception.Response.StatusCode.value__ -ne 404) { throw }
    }
    $commitBody = @{ message = "Publish portfolio to $Branch"; tree = $tree.sha }
    if ($parents.Count -gt 0) { $commitBody.parents = $parents }
    $commit = Invoke-GitHubJson -Method Post -Uri "$apiRoot/git/commits" -Body $commitBody
    if ($existingRef) {
        Invoke-GitHubJson -Method Patch -Uri "$apiRoot/git/refs/heads/$Branch" -Body @{ sha = $commit.sha; force = $true } | Out-Null
    } else {
        Invoke-GitHubJson -Method Post -Uri "$apiRoot/git/refs" -Body @{ ref = "refs/heads/$Branch"; sha = $commit.sha } | Out-Null
    }
    return $commit.sha
}

# Git data endpoints require an initialized repository. Seed main once when the
# repository has no commits; the real main tree below replaces this marker.
try {
    Invoke-RestMethod -Uri "$apiRoot/git/ref/heads/main" -Headers $headers | Out-Null
} catch {
    if ($_.Exception.Response.StatusCode.value__ -ne 404 -and $_.Exception.Response.StatusCode.value__ -ne 409) { throw }
    Invoke-GitHubJson -Method Put -Uri "$apiRoot/contents/.repository-initialized" -Body @{
        message = 'Initialize portfolio repository'
        content = [Convert]::ToBase64String([Text.Encoding]::UTF8.GetBytes('Portfolio repository initialized.'))
    } | Out-Null
}

$sourceFiles = @(
    (Get-ChildItem -Path '.openai' -File -Recurse -Force).FullName
    (Resolve-Path 'README.md').Path
    (Get-ChildItem -Path 'dist' -File -Recurse -Force).FullName
    (Resolve-Path 'publish-github-pages.ps1').Path
    (Resolve-Path 'publish-github-api.ps1').Path
)
$mainSha = Publish-Branch -Branch 'main' -Root '.' -Files $sourceFiles
$pageFiles = (Get-ChildItem -Path 'dist' -File -Recurse -Force).FullName
$pagesSha = Publish-Branch -Branch 'gh-pages' -Root 'dist' -Files $pageFiles

$repo = Invoke-GitHubJson -Method Patch -Uri $apiRoot -Body @{ default_branch = 'main' }
$pagesBody = @{ source = @{ branch = 'gh-pages'; path = '/' } }
try {
    $pages = Invoke-GitHubJson -Method Post -Uri "$apiRoot/pages" -Body $pagesBody
} catch {
    if ($_.Exception.Response.StatusCode.value__ -ne 409 -and $_.Exception.Response.StatusCode.value__ -ne 422) { throw }
    $pages = Invoke-GitHubJson -Method Put -Uri "$apiRoot/pages" -Body $pagesBody
}

[pscustomobject]@{
    repository = $repo.html_url
    pages_url = $pages.html_url
    main_sha = $mainSha
    pages_sha = $pagesSha
} | ConvertTo-Json

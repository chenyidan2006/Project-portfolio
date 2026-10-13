$ErrorActionPreference = 'Stop'

$repoName = 'ppg-vascular-portfolio'
$description = 'PPG vascular parameter monitoring system portfolio'
$credentialRequest = "protocol=https`nhost=github.com`n`n"
$credentialLines = $credentialRequest | git credential fill
$credential = @{}
foreach ($line in $credentialLines) {
    if ($line -match '^([^=]+)=(.*)$') {
        $credential[$matches[1]] = $matches[2]
    }
}

if (-not $credential.ContainsKey('password')) {
    throw 'GitHub credential is unavailable in Git Credential Manager.'
}

$headers = @{
    Authorization = "Bearer $($credential['password'])"
    Accept = 'application/vnd.github+json'
    'X-GitHub-Api-Version' = '2022-11-28'
    'User-Agent' = 'Codex-Portfolio-Publisher'
}

$account = Invoke-RestMethod -Uri 'https://api.github.com/user' -Headers $headers
$owner = $account.login
$repoUri = "https://api.github.com/repos/$owner/$repoName"

try {
    $repo = Invoke-RestMethod -Uri $repoUri -Headers $headers
} catch {
    if ($_.Exception.Response.StatusCode.value__ -ne 404) { throw }
    $body = @{
        name = $repoName
        description = $description
        private = $false
        has_issues = $true
        has_projects = $false
        has_wiki = $false
    } | ConvertTo-Json
    $repo = Invoke-RestMethod -Method Post -Uri 'https://api.github.com/user/repos' -Headers $headers -Body $body -ContentType 'application/json'
}

if ($repo.private) {
    $body = @{ private = $false } | ConvertTo-Json
    $repo = Invoke-RestMethod -Method Patch -Uri $repoUri -Headers $headers -Body $body -ContentType 'application/json'
}

$remoteUrl = "https://github.com/$owner/$repoName.git"
$existingRemote = git remote | Where-Object { $_ -eq 'origin' }
if ($existingRemote) {
    git remote set-url origin $remoteUrl
} else {
    git remote add origin $remoteUrl
}

git add .openai README.md dist publish-github-pages.ps1
$changes = git status --porcelain
if ($changes) {
    git commit -m 'Publish PPG project portfolio'
}
git branch -M main
git push -u origin main

$existingPagesBranch = git branch --list gh-pages
if ($existingPagesBranch) {
    git branch -D gh-pages
}
git subtree split --prefix dist -b gh-pages
git push origin gh-pages --force

$pagesBody = @{ source = @{ branch = 'gh-pages'; path = '/' } } | ConvertTo-Json -Depth 3
try {
    $pages = Invoke-RestMethod -Method Post -Uri "$repoUri/pages" -Headers $headers -Body $pagesBody -ContentType 'application/json'
} catch {
    if ($_.Exception.Response.StatusCode.value__ -ne 409 -and $_.Exception.Response.StatusCode.value__ -ne 422) { throw }
    $pages = Invoke-RestMethod -Method Put -Uri "$repoUri/pages" -Headers $headers -Body $pagesBody -ContentType 'application/json'
}

$visibility = if ($repo.private) { 'private' } else { 'public' }
[pscustomobject]@{
    owner = $owner
    repository = $repo.html_url
    visibility = $visibility
    pages_url = $pages.html_url
} | ConvertTo-Json

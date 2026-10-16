"""Check local HTML pages, resources and fragment links with Python stdlib."""
from html.parser import HTMLParser
from pathlib import Path
from urllib.parse import urlsplit, unquote
import sys

ROOT = Path(__file__).resolve().parents[1] / "dist"
class Page(HTMLParser):
    def __init__(self):
        super().__init__(convert_charrefs=True)
        self.ids = set()
        self.links = []
        self.errors = []
    def handle_starttag(self, tag, attrs):
        a = dict(attrs)
        if "id" in a:
            if a["id"] in self.ids:
                self.errors.append("duplicate id: " + a["id"])
            self.ids.add(a["id"])
        for key in ("href", "src", "data-original"):
            if a.get(key):
                self.links.append(a[key])
        if tag == "img" and "alt" not in a:
            self.errors.append("image without alt")

pages = {}
errors = []
for path in ROOT.rglob("*.html"):
    page = Page()
    page.feed(path.read_text(encoding="utf-8-sig"))
    pages[path.resolve()] = page
    errors.extend(f"{path.name}: {e}" for e in page.errors)
checked = 0
for path, page in pages.items():
    for href in page.links:
        url = urlsplit(href)
        if url.scheme or url.netloc:
            continue
        target = (ROOT / unquote(url.path).lstrip("/")) if url.path.startswith("/") else (path.parent / unquote(url.path)) if url.path else path
        target = target.resolve()
        if not target.is_relative_to(ROOT.resolve()):
            errors.append(f"{path.name}: link escapes dist: {href}")
            continue
        if target.is_dir():
            target = target / "index.html"
        checked += 1
        if not target.exists():
            errors.append(f"{path.name}: missing {href}")
        elif url.fragment and target in pages and unquote(url.fragment) not in pages[target].ids:
            errors.append(f"{path.name}: missing anchor {href}")
if errors:
    print("\n".join(errors))
    sys.exit(1)
print(f"PASS: {len(pages)} HTML pages, {checked} local links/resources; IDs and image alt checked.")

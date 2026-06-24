# kemisortering.dk

Marketing site for Dansk Kemisortering A/S — a single-page static site at
[www.kemisortering.dk](https://www.kemisortering.dk/).

Static HTML + Tailwind v4 (compiled locally), served by Caddy on a VPS at
`hel1.x2q.net`. No JavaScript framework, no runtime build, no database.

## Repository layout

```
.
├── index.html             # the entire site
├── src/styles.css         # Tailwind v4 source (@theme tokens + custom CSS)
├── css/styles.css         # compiled output (committed; needed for deploy)
├── img/                   # logos (SVG) and photos (webp + JPG/PNG fallbacks)
├── apple-touch-icon.png   # served from /apple-touch-icon.png
├── robots.txt
├── sitemap.xml
├── llms.txt
└── Makefile               # build / watch / deploy
```

The HTML pulls images out of `img/`, the favicon stack out of `img/` + the
root, and one stylesheet from `css/styles.css`. There are no other runtime
dependencies.

## Prerequisites

- [`tailwindcss`](https://tailwindcss.com/) v4 standalone CLI on `$PATH`
  (the Makefile invokes it as `tailwindcss`)
- `rsync` + SSH access to `root@hel1.x2q.net` (deploy target)
- Optional for regenerating raster assets: `magick` (ImageMagick),
  `cwebp`, `potrace`

## Local development

Serve the directory with any static server:

```sh
python3 -m http.server 8765
# then open http://127.0.0.1:8765
```

While editing styles or HTML, run the watcher in another terminal so
`css/styles.css` rebuilds on each change:

```sh
make watch
```

Tailwind v4 only emits CSS for utility classes it actually sees in
`index.html`. Adding a new class to the HTML requires a rebuild — `make
watch` handles that incrementally; `make build` does a one-shot minified
build.

## Deploy

```sh
make deploy
```

That runs `make build` first, then `rsync`es `index.html` and
`css/styles.css` to `root@hel1.x2q.net:/data/sites/kemisortering.dk/`.
Caddy serves the directory directly; there is no reload or restart step.

If you change images, root files (`robots.txt`, `sitemap.xml`,
`llms.txt`), favicons, or the SVG logos, push them explicitly:

```sh
rsync -av --relative img/<changed-file> root@hel1.x2q.net:/data/sites/kemisortering.dk/
```

Or just rsync the whole tree (skip the noise):

```sh
rsync -av --delete \
  --exclude='.git/' --exclude='.DS_Store' --exclude='src/' --exclude='Makefile' --exclude='README.md' \
  ./ root@hel1.x2q.net:/data/sites/kemisortering.dk/
```

## Asset workflow

- **Logos** (`img/logo.svg`, `img/logo-tall.svg`) are hand-composed SVG
  with a teal `<rect>` background and traced bottle paths.
- **Favicons** (`img/favicon.png`, `img/favicon-48.png`,
  `img/favicon-192.png`, `apple-touch-icon.png`) are rasterised from
  `img/logo.svg` — regenerate with:
  ```sh
  magick -background none -density 600 img/logo.svg -resize 192x192 img/favicon-192.png
  magick -background none -density 600 img/logo.svg -resize 48x48  img/favicon-48.png
  magick -background none -density 600 img/logo.svg -resize 32x32  img/favicon.png
  magick -background none -density 600 img/logo.svg -resize 180x180 apple-touch-icon.png
  ```
- **Photos** (hero, bottles, process steps) ship as `<picture>` with a
  `webp` source and a JPG/PNG fallback. Hero variants are generated at
  768 / 1024 / 1536 px wide so the preload + srcset can pick the right
  one. To regenerate variants of a new PNG, see commands in commit
  `d213932`.

## Out-of-repo configuration

A few things the SEO/security scanner expects are not fixable by changing
files in this repo:

| Concern | Lives in |
|---|---|
| `Strict-Transport-Security`, `X-Content-Type-Options`, `Referrer-Policy`, `Permissions-Policy`, `Content-Security-Policy` headers | Caddyfile on `hel1.x2q.net` |
| HSTS preload eligibility | same |
| SPF, DMARC, CAA records | DNS at the registrar for `kemisortering.dk` |
| MX / DKIM | already configured (Google Workspace) |

Recommended snippets for these are in the git history (see commit
`d213932` body and surrounding chat context).

# kemisortering.dk

Marketing site for Dansk Kemisortering A/S — a single-page static site at
[www.kemisortering.dk](https://www.kemisortering.dk/).

Built with [Zola](https://www.getzola.org/) (static site generator) and
Tailwind CSS v4 (compiled locally), served by Caddy on a VPS at
`hel1.x2q.net`.

## Repository layout

```
.
├── config.toml            # site config + [extra] contact data (single source of truth)
├── content/
│   └── _index.md          # homepage front matter (template = index.html)
├── templates/
│   ├── base.html          # <head>, nav, footer, JSON-LD, scroll script
│   ├── index.html         # homepage sections (extends base.html)
│   └── robots.txt         # robots.txt template (Zola generates /robots.txt)
├── src/styles.css         # Tailwind v4 source (@theme tokens + custom CSS)
├── static/
│   ├── css/styles.css      # compiled Tailwind (build output, committed)
│   ├── img/                # logos (SVG) + photos (webp + JPG/PNG fallbacks)
│   ├── apple-touch-icon.png
│   └── llms.txt
├── public/                # Zola build output (git-ignored)
└── Makefile               # css / build / serve / deploy
```

Everything under `static/` is copied verbatim to the site root. Zola
generates `sitemap.xml` and `robots.txt` automatically.

### Contact data lives in one place

Phone, email, addresses, and CVR are defined once in `config.toml` under
`[extra]` and referenced from the templates (footer, contact card, JSON-LD,
meta). To change the phone number or add an address, edit `config.toml` —
not the markup.

## Prerequisites

- [`zola`](https://www.getzola.org/documentation/getting-started/installation/) (v0.22+)
- [`tailwindcss`](https://tailwindcss.com/) v4 standalone CLI on `$PATH`
- `rsync` + SSH access to `root@hel1.x2q.net`
- Optional, for regenerating raster assets: `magick`, `cwebp`, `potrace`

## Local development

```sh
make serve        # zola dev server with live reload at http://127.0.0.1:1111
make css-watch    # in a second terminal: rebuild CSS on change
```

Tailwind v4 only emits CSS for utility classes it sees in `templates/`.
Adding a class to a template requires a CSS rebuild — `make css-watch`
handles it incrementally; `make css` does a one-shot minified build.

## Deploy

```sh
make deploy
```

That builds the CSS, runs `zola build` into `public/`, then mirrors
`public/` to `root@hel1.x2q.net:/data/sites/kemisortering.dk/` with
`rsync --delete`. Caddy serves the directory directly — no reload step.

> `rsync --delete` makes the server match `public/` exactly. Anything in
> the deploy directory that isn't produced by the build will be removed.

## Asset workflow

- **Logos** (`static/img/logo.svg`, `static/img/logo-tall.svg`) are
  hand-composed SVG — a teal `<rect>` background plus traced bottle paths.
- **Favicons** (`static/img/favicon*.png`, `static/apple-touch-icon.png`)
  are rasterised from `logo.svg`:
  ```sh
  magick -background none -density 600 static/img/logo.svg -resize 192x192 static/img/favicon-192.png
  magick -background none -density 600 static/img/logo.svg -resize 48x48  static/img/favicon-48.png
  magick -background none -density 600 static/img/logo.svg -resize 32x32  static/img/favicon.png
  magick -background none -density 600 static/img/logo.svg -resize 180x180 static/apple-touch-icon.png
  ```
- **Photos** ship as `<picture>` with a `webp` source and a JPG/PNG
  fallback. Hero variants exist at 768 / 1024 / 1536 px for the preload +
  srcset.

## Out-of-repo configuration

Some scanner expectations are not fixable by changing files in this repo:

| Concern | Lives in |
|---|---|
| Security headers (HSTS, CSP, X-Content-Type-Options, Referrer-Policy, Permissions-Policy) | Caddyfile on `hel1.x2q.net` |
| SPF, DMARC, CAA records | DNS at the registrar for `kemisortering.dk` |
| MX / DKIM | already configured (Google Workspace) |

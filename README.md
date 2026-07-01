# Personal site

A [Quarto](https://quarto.org) website at [haigh.bio](https://haigh.bio), deployed to GitHub Pages.

## Structure

Each page is a directory containing `index.qmd`, which renders to `<dir>/index.html` and is
served at the clean URL `<dir>/` (see `bin/clean-urls.sh`).

```
.
├── _quarto.yml                 # site config (title, nav, theme)
├── _quarto-production.yml      # production profile — excludes drafts + hidden from deploy
├── index.qmd                   # home page
├── about/index.qmd             # about page
├── blog/
│   ├── index.qmd               # blog listing (auto-generated from posts/)
│   ├── posts/                  # published posts (one folder per post)
│   │   ├── _metadata.yml       # defaults applied to every post (incl. giscus comments)
│   │   └── <slug>/index.qmd
│   └── drafts/                 # WIP posts — excluded from production render
│       ├── _metadata.yml
│       └── <slug>/index.qmd
├── hidden/                     # unlisted pages — excluded from production render
├── projects/index.qmd          # projects & decks page
├── personal/index.qmd          # ceramics + photography galleries (draft)
├── life/index.qmd              # Game of Life (canvas) easter egg
├── reaction-diffusion/index.qmd# Gray-Scott reaction-diffusion (WebGL) easter egg
├── decks/                      # Reveal.js deck sources + exported PDF/PPTX
│   └── <slug>/index.qmd
├── img/                        # gallery images for the Personal page
│   ├── ceramics/               # square images, 3-col grid
│   └── photo/                  # 3:2 landscape, 2-col grid
├── bin/                        # build helpers (new-post.sh, clean-urls.sh)
├── styles.css                  # site CSS tweaks
└── .github/workflows/
    ├── publish.yml             # auto-deploy on push to main
    └── check.yml               # render check on pull requests
```

## Local development

### One-time setup

1. Install Quarto: `brew install --cask quarto` (or download from [quarto.org](https://quarto.org/docs/get-started/))
2. (Optional) For a better editor experience, use VS Code with the [Quarto extension](https://marketplace.visualstudio.com/items?itemName=quarto.quarto).
3. Install the lightbox extension (powers click-to-zoom on the Personal page):
   ```bash
   quarto add quarto-ext/lightbox
   ```
   This creates an `_extensions/` directory which should be committed.

### Preview locally

```bash
quarto preview
```

This includes draft posts and hidden pages and opens a live-reloading preview at
`http://localhost:4242`.

### Render once

```bash
quarto render                        # all pages (local)
quarto render --profile production   # production targets only (matches CI)
```

Output goes to `_site/`.

## Deploy to GitHub Pages

Pushes to `main` trigger `.github/workflows/publish.yml`, which renders the site (excluding
`blog/drafts/` and `hidden/`) and publishes to the `gh-pages` branch. Pull requests run
`.github/workflows/check.yml`, which renders the same production targets without publishing.

### One-time setup

1. Create a new repo on GitHub (public, or private with GitHub Pro for Pages on private).
2. Initialise and push:
   ```bash
   git init
   git add .
   git commit -m "Initial scaffold"
   git branch -M main
   git remote add origin https://github.com/stevehaigh/quarto-site-builder.git
   git push -u origin main
   ```
3. Create an empty `gh-pages` branch (the workflow needs it to exist):
   ```bash
   git checkout --orphan gh-pages
   git reset --hard
   git commit --allow-empty -m "Initialise gh-pages"
   git push origin gh-pages
   git checkout main
   ```
4. In GitHub: **Settings → Pages → Build and deployment**
   - Source: *Deploy from a branch*
   - Branch: `gh-pages` / `/ (root)`
5. Push to `main` — the publish workflow renders and deploys.

The site is live at [haigh.bio](https://haigh.bio) (GitHub Pages default URL:
`https://stevehaigh.github.io/quarto-site-builder/`).

## Custom domain (Cloudflare)

1. Register the domain at [Cloudflare Registrar](https://www.cloudflare.com/products/registrar/) (at-cost pricing).
2. In Cloudflare DNS, add records pointing to GitHub Pages:
   - For an apex domain (`example.com`), add four A records to:
     ```
     185.199.108.153
     185.199.109.153
     185.199.110.153
     185.199.111.153
     ```
     (set proxy status to **DNS only** — grey cloud — to avoid HTTPS cert issues with GitHub Pages)
   - For `www`, add a CNAME pointing to `stevehaigh.github.io`.
3. In GitHub: **Settings → Pages → Custom domain**, enter your domain. GitHub will create a `CNAME` file in the `gh-pages` branch and provision an HTTPS cert (takes a few minutes).
4. Tick **Enforce HTTPS** once the cert is issued.
5. Update `site-url` in `_quarto.yml` to your new domain.

## Adding a blog post

```bash
bin/new-post.sh my-new-post "My new post"   # scaffolds blog/drafts/my-new-post/index.qmd
quarto preview                              # drafts are included in local preview
$EDITOR blog/drafts/my-new-post/index.qmd
```

When ready to publish:

1. Move the folder from `blog/drafts/<slug>/` to `blog/posts/<slug>/`.
2. Remove `draft: true` from the front matter.
3. Push to `main` — the site rebuilds.

Draft and hidden pages are excluded from production render, search, listings, and sitemap.

## Adding a slide deck

1. Create a Reveal.js deck source at `decks/<slug>/index.qmd` (see existing decks for examples).
2. Build HTML, PPTX, and PDF locally:
   ```bash
   decks/<slug>/build.sh
   ```
   PDF export uses headless Chrome locally; commit the generated PDF so CI can deploy it.
3. Add links in `projects/index.qmd`.
4. Commit and push.

## Adding gallery images

The `personal/index.qmd` page currently references placeholder SVGs in `img/ceramics/` and `img/photo/`, and is marked `draft: true`. To add your own work:

1. Drop your images into the relevant folder (`img/ceramics/` or `img/photo/`). See the `README.md` in each folder for size/format guidance.
2. Update the image references in `personal/index.qmd` — change `placeholder-01.svg` to your filename (and remove placeholder files you no longer need).
3. Remove `draft: true` from the front matter to publish the page.
4. Commit and push.

The lightbox extension (installed in one-time setup) gives each image click-to-zoom for free. Captions from the Markdown `![Caption](path)` syntax appear under the zoomed image.

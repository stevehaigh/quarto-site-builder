# Personal site

A [Quarto](https://quarto.org) website, deployed to GitHub Pages.

## Structure

```
.
├── _quarto.yml          # site config (title, nav, theme)
├── index.qmd            # home page
├── about.qmd            # about page
├── blog.qmd             # blog listing (auto-generated from posts/)
├── projects.qmd         # projects & decks page
├── posts/               # blog posts (one folder per post)
│   ├── _metadata.yml    # defaults applied to every post
│   └── welcome/
│       └── index.qmd
├── decks/               # drop slide PDFs here
├── styles.css           # site CSS tweaks
└── .github/workflows/
    └── publish.yml      # auto-deploy on push to main
```

## Local development

### One-time setup

1. Install Quarto: `brew install --cask quarto` (or download from [quarto.org](https://quarto.org/docs/get-started/))
2. (Optional) For a better editor experience, use VS Code with the [Quarto extension](https://marketplace.visualstudio.com/items?itemName=quarto.quarto).

### Preview locally

```bash
quarto preview
```

This opens a live-reloading preview at `http://localhost:4242`.

### Render once

```bash
quarto render
```

Output goes to `_site/`.

## Deploy to GitHub Pages

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
5. Push to `main` — the Action in `.github/workflows/publish.yml` renders and publishes.

Your site will be at `https://stevehaigh.github.io/quarto-site-builder/`.

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

## Things to change before going live

Search the repo for `stevehaigh`, `quarto-site-builder`, `you@example.com`, and `example.com` — those are the placeholders to replace.

## Adding a blog post

```bash
mkdir posts/my-new-post
$EDITOR posts/my-new-post/index.qmd
```

Use `posts/welcome/index.qmd` as a template. Push to main, site rebuilds.

## Adding a slide deck

1. Export your deck to PDF.
2. Drop it in `decks/`.
3. Add a link to it in `projects.qmd`.
4. Commit and push.

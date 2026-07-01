# Decks

Reveal.js slide sources live in `decks/<slug>/index.qmd`. Each deck has a `build.sh` that renders HTML and PPTX via Quarto, then prints PDF via headless Chrome (local only — commit the PDF so CI can deploy it).

```bash
decks/<slug>/build.sh           # HTML + PPTX + PDF
decks/<slug>/build.sh --no-pdf  # skip PDF if Chrome isn't available
```

Link to built decks from `projects/index.qmd`. Standalone PDF/PPTX drops (e.g. `academic-template.pptx`) also go here.

## Why commit PDF?

- Renders inline in browsers — no download needed
- Far smaller than equivalent `.pptx` in git
- Stable across viewers
- CI has no Chrome for print-to-PDF, so PDFs are built locally and checked in

To export from PowerPoint without Quarto: File → Export → PDF.

To export from Keynote: File → Export To → PDF.

# Photography

Drop your photographs here as `.jpg`.

The page in `personal.qmd` references `placeholder-01.svg` through `placeholder-04.svg`. Replace those references with your real filenames once you've added images.

## Recommended

- **Aspect ratio**: a consistent ratio across the gallery looks tidier. 3:2 landscape is the safest default.
- **Long edge**: 1600 px is plenty for web.
- **Format**: JPEG, quality ~85. Keep file sizes under ~500 KB.
- **Naming**: lowercase, hyphens, descriptive — `dolomites-dusk-2026.jpg`.

## Batch resize on macOS

```bash
sips -Z 1600 *.jpg                  # resize long edge to 1600 px
exiftool -gps:all= *.jpg            # strip GPS data (install: brew install exiftool)
```

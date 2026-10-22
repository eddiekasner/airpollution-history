# A Brief History of Air Pollution

Lecture slides on air pollution sources, exposure pathways, and major air quality events from the Meuse Valley (1930) to recent wildfire smoke, with related studies and policy.

## Versions

| Version | Files |
| --- | --- |
| ENVH 111, University of Washington (2026 video lecture) | `envh111-airpollution-history.Rmd`, `envh111-airpollution-history.pdf` (slides for recording), `envh111-airpollution-history-accessible.pdf` and `.pptx` (screen-reader accessible, for Canvas), `envh111-talking-points.md` |
| St. Catherine University guest lecture (October 2018) | `airpollution-lecture-oct2018.Rmd`, `airpollution-lecture-oct2018.pdf` |

## Rendering

The `.Rmd` files render to Beamer PDF slides with R Markdown. Run them from the repository root so the `images/` paths resolve.

## Accessible version (ENVH 111)

Alt text for every image lives in the `.Rmd`, in the image brackets: `![alt text](images/file.png)`. `slide-images.lua` keeps the Beamer slides looking the same and keeps images and credits together in PowerPoint.

To rebuild the accessible files after editing the slides:

1. Knit `envh111-airpollution-history.Rmd` to PowerPoint (RStudio: Knit > Knit to PowerPoint). This uses `envh111-reference.pptx` for layout.
2. Copy the alt text into the PowerPoint file (pandoc does not do this itself):
   `python3 add-alt-text.py envh111-airpollution-history.Rmd envh111-airpollution-history.pptx`
3. Open the `.pptx` in PowerPoint, run Review > Check Accessibility, then save as PDF with accessibility tags turned on. LibreOffice also works: File > Export as PDF with "Universal Accessibility (PDF/UA)" checked.

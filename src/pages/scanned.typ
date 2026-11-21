#import "../layouts/page.typ": page-footer, page-header
#import "common.typ": source-path

#let scanned-pages(
  config,
  file,
  pages: (1,),
  page-style: "empty",
  anchor: none,
) = {
  for (index, number) in pages.enumerate() {
    pagebreak(weak: true)
    set page(
      paper: "a4",
      margin: 0pt,
      header: none,
      footer: none,
      numbering: none,
    )
    if index == 0 and anchor != none {
      // Keep a semantic heading for the TOC and running header without drawing it over the scan.
      show heading: it => none
      anchor
    }
    place(top + left, image(
      source-path(file),
      page: number,
      width: 210mm,
      height: 297mm,
      fit: "contain",
    ))
    if page-style == "plain" {
      if config.degree != "bachelor" {
        place(top + center, dy: 2.2cm, box(width: 15cm, page-header(
          config,
          compensate-ascent: false,
        )))
      }
      place(
        bottom + center,
        dy: if config.degree == "bachelor" { -1.5cm } else { -2.2cm },
        page-footer(config),
      )
    }
    pagebreak(weak: true)
  }
}

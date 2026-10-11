#import "../layouts/pagebreak.typ": clear-page
#import "common.typ": _inside, _source-path

#let _scanned-page-overlay(env, page-style) = {
  let config = env.config
  if page-style == "plain" {
    let width = 15cm
    if config.degree != "bachelor" {
      place(
        top + center,
        dy: 2.2cm,
        box(width: width, (env.layout.scanned-page-header)()),
      )
    }
    place(
      bottom + center,
      dy: if config.degree == "bachelor" { -1.5cm } else { -2.2cm },
      (env.layout.page-footer)(),
    )
  }
}

#let _scanned-pages(
  env,
  file,
  pages: (1,),
  page-style: "empty",
  anchor: none,
) = _inside(
  env,
  config => {
    assert(
      page-style in ("plain", "empty"),
      message: "thuthesis: invalid page style",
    )
    assert(
      type(file) in (str, bytes),
      message: "thuthesis: scanned-pages file must be a path or bytes",
    )
    assert(
      type(pages) == array and pages.len() > 0,
      message: "thuthesis: scanned-pages pages must be a non-empty array",
    )
    for (index, number) in pages.enumerate() {
      assert(
        type(number) == int and number >= 1,
        message: "thuthesis: every scanned page number must be a positive integer",
      )
      clear-page(weak: true)
      set page(
        paper: "a4",
        margin: 0pt,
        header: none,
        footer: none,
        numbering: none,
      )
      if index == 0 and anchor != none {
        // The scan supplies its own title. Keep a semantic heading for the TOC and running header.
        show heading: it => none
        anchor
      }
      place(top + left, image(
        _source-path(file),
        page: number,
        width: 210mm,
        height: 297mm,
        fit: "contain",
      ))
      _scanned-page-overlay(env, page-style)
      clear-page(weak: true)
    }
  },
)

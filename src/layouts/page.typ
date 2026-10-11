#import "../config.typ": serif-fonts
#import "body-size.typ": _body-top-skip
#import "chapter-title.typ": chapter-label, render-title
#import "headings.typ": _heading-number-at, _heading-number-gap
#import "runtime.typ": thuthesis-runtime
#import "../utils/text.typ": bp, line-height, tex-pt

#let _header-separation = 0.3cm

#let _header-title(config) = context {
  let current-page = here().page()
  let chapters = query(heading.where(level: 1)).filter(
    chapter => chapter.location().page() <= current-page,
  )
  if chapters.len() > 0 {
    let chapter = chapters.last()
    let location = chapter.location()
    let appendix = (thuthesis-runtime.appendix-at)(location)
    let numbered = chapter.numbering != none
    let selected = (thuthesis-runtime.heading-header-at)(location)
    if selected != none {
      let derived = selected == auto
      if numbered and derived {
        let number = _heading-number-at(chapter, appendix)
        chapter-label(config, number, appendix: appendix)
        _heading-number-gap(config)
      }
      render-title(
        config,
        if derived { chapter.body } else { selected },
        kind: (thuthesis-runtime.heading-kind-at)(location),
        target: "header",
        numbered: numbered and derived,
      )
    }
  }
}

#let page-header(config, compensate-ascent: true) = context {
  // The header is evaluated once for each page, making it the explicit page
  // boundary for page-scoped footnotes.
  if config.footnote-numbering == "page" { counter(footnote).update(0) }
  if config.degree != "bachelor" {
    // thuthesis.dtx:3347 uses bare `\wuhao`; the named-size macro's
    // default multiplier is 1.3, so retain the source relationship here.
    let header-size = bp(10.5)
    block(width: 100%)[
      #align(center, move(
        dy: if compensate-ascent { _header-separation } else { 0pt },
        line-height(
          header-size,
          header-size * 1.3,
          text(font: serif-fonts(config), _header-title(config)),
        ),
      ))
      #v(tex-pt(3))
      #line(length: 100%, stroke: bp(0.75))
    ]
  }
}

#let _footer-size(config) = if (
  config.degree == "bachelor" and config.language == "english"
) { bp(12) } else { bp(10.5) }

#let _page-numbering(..numbers) = context {
  let matter = (thuthesis-runtime.matter-at)(here())
  numbering(
    if matter == "front" { "I" } else { "1" },
    ..numbers,
  )
}

#let page-footer(config, numbering: _page-numbering) = context {
  align(center, text(
    font: serif-fonts(config),
    size: _footer-size(config),
    counter(page).display(numbering),
  ))
}

#let _page-set(config, body) = {
  set page(
    paper: "a4",
    // Preserve the 3cm bottom boundary, while reproducing TeX's `\topskip`
    // before the first line on continuation pages.
    margin: (top: 3cm + _body-top-skip, rest: 3cm),
    header: page-header(config),
    // The larger body inset must not move the header with it. TeX's rule is
    // a one-sided box, while Typst strokes around its path, hence half the
    // declared rule width is subtracted at this boundary.
    header-ascent: _header-separation + _body-top-skip - bp(0.75) / 2,
    footer: page-footer(config),
    // TeX's footskip addresses the footer baseline, while Typst lowers the
    // footer from the text area's bottom edge by its frame's top-to-baseline
    // distance. ThuThesis's text frame puts that baseline at 0.8em.
    footer-descent: (
      if config.degree == "bachelor" { 1.5cm } else { 0.8cm }
    )
      - 0.8 * _footer-size(config),
    numbering: _page-numbering,
  )
  body
}

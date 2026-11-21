#import "chapter-title.typ": chapter-label, render-title
#import "headings.typ": heading-number-at, heading-number-gap
#import "runtime.typ": runtime-at
#import "../utils/text.typ": body-top-skip, bp, line-height, tex-pt

#let _header-separation = 0.3cm

#let clear-double-page(config) = if config.output == "print" {
  let style = config.blank-page-style
  set page(header: none) if style != "no-numbering"
  set page(footer: none, numbering: none) if style != "no-header"
  if style == "blank-only" { [#metadata(none) <__tntt:pagebreak-blank-only>] }
  pagebreak(to: "odd", weak: true)
} else {
  pagebreak(weak: true)
}

#let _header-title(config) = context {
  let current-page = here().page()
  let chapters = query(heading.where(level: 1)).filter(ch => (
    ch.location().page() <= current-page
  ))
  if chapters.len() > 0 {
    let chapter = chapters.last()
    let state = runtime-at(chapter.location())
    let selected = state.heading-header
    if selected != none {
      let numbered = chapter.numbering != none
      let derived = selected == auto
      let appendix = state.matter == "appendix"
      if numbered and derived {
        chapter-label(
          config,
          heading-number-at(chapter, appendix),
          appendix: appendix,
        )
        heading-number-gap(config)
      }
      render-title(
        config,
        if derived { chapter.body } else { selected },
        kind: state.heading-kind,
        numbered: numbered and derived,
      )
    }
  }
}

#let page-header(config, compensate-ascent: true) = context {
  if config.footnote-numbering == "page" { counter(footnote).update(0) }
  if config.degree != "bachelor" {
    let header-size = bp(10.5)
    block(width: 100%)[
      #align(center, move(
        dy: if compensate-ascent { _header-separation } else { 0pt },
        line-height(header-size, header-size * 1.3, text(
          font: config.fonts.SongTi,
          _header-title(config),
        )),
      ))
      #v(tex-pt(3))
      #line(length: 100%, stroke: bp(0.75))
    ]
  }
}

#let _footer-size(config) = if (
  config.degree == "bachelor" and config.language == "english"
) { bp(12) } else { bp(10.5) }

#let _page-numbering(..numbers) = context numbering(
  if runtime-at(here()).matter == "front" { "I" } else { "1" },
  ..numbers,
)

#let page-footer(config) = context align(
  center,
  text(
    font: config.fonts.SongTi,
    size: _footer-size(config),
    counter(page).display(_page-numbering),
  ),
)

#let page-set(config, body) = {
  set page(
    paper: "a4",
    margin: (top: 3cm + body-top-skip, rest: 3cm),
    header: page-header(config),
    header-ascent: _header-separation + body-top-skip - bp(0.75) / 2,
    footer: page-footer(config),
    footer-descent: (if config.degree == "bachelor" { 1.5cm } else { 0.8cm })
      - 0.8 * _footer-size(config),
    numbering: _page-numbering,
  )
  body
}

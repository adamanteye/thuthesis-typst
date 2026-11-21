#import "../config.typ": chapter-names, chinese
#import "../layouts/chapter-title.typ": chapter-label, render-title
#import "../layouts/runtime.typ": runtime-at
#import "common.typ": front-title-outlined, special-chapter
#import "../utils/text.typ": (
  body-baseline, body-font-size, body-top-skip, bp, tex-pt,
)

#let page-at(location) = numbering(
  if runtime-at(location).matter == "front" { "I" } else { "1" },
  counter(page).at(location).first(),
)

// TeX's `titlerule*[4bp]{.}` advances by an invariant 4bp cell.
#let dot-leader = repeat(
  box(width: bp(4), align(right, [.])),
  gap: 0pt,
  justify: false,
)

#let fixed-line-block(body, before: 0pt) = block(
  above: body-top-skip + before,
  below: 0pt,
  width: 100%,
  breakable: false,
  inset: (
    top: 0.7 * body-baseline - tex-pt(12),
    bottom: 0.3 * body-baseline - 0.2 * body-font-size,
  ),
  body,
)

#let fixed-line-start(before: 0pt) = v(body-top-skip + before, weak: false)

// English graduate TOC `\heiti` switches only the CJK family while Latin stays serif.
#let _toc-chapter-fonts(config) = if (
  not chinese(config) and config.degree != "bachelor"
) {
  (config.fonts.SongTi.first(),) + config.fonts.HeiTi.slice(1)
} else {
  config.fonts.HeiTi
}

#let _toc-number(config, it) = context {
  let el = it.element
  if el.numbering == none { return [] }
  let loc = el.location()
  let appendix = runtime-at(loc).matter == "appendix"
  let values = counter(heading).at(loc)
  if it.level == 1 {
    chapter-label(
      config,
      numbering(if appendix { "A" } else { "1" }, values.first()),
      appendix: appendix,
    )
  } else {
    numbering(if appendix { "A.1.1.1" } else { el.numbering }, ..values)
  }
}

#let _toc-gap(config) = if (
  (config.degree == "bachelor" and chinese(config))
    or (config.degree != "bachelor" and not chinese(config))
) { text(" ") } else { h(1em) }

#let _toc-entry(config, it) = context {
  set par(first-line-indent: 0pt)
  let loc = it.element.location()
  let state = runtime-at(loc)
  if state.matter in ("appendix", "back") and it.level > 1 { return none }
  let numbered = it.element.numbering != none
  let en-bachelor = config.degree == "bachelor" and not chinese(config)
  let indent = if not numbered { 0pt } else if en-bachelor {
    (it.level - 1) * 0.5cm
  } else { (it.level - 1) * 1em }
  let chapter-entry = numbered and it.level == 1
  let chapter-fonts = _toc-chapter-fonts(config)
  let prefix = if numbered {
    let body = [#_toc-number(config, it)#_toc-gap(config)]
    if chapter-entry { text(font: chapter-fonts, body) } else { body }
  } else { none }
  let title = if it.level == 1 {
    text(
      font: chapter-fonts,
      render-title(
        config,
        it.body(),
        kind: state.heading-kind,
        outline: true,
        numbered: numbered,
      ),
    )
  } else { it.body() }
  let inner = [#title#box(width: 1fr, it.fill)#text(
      font: config.fonts.SongTi,
      page-at(loc),
    )]
  fixed-line-block(
    pad(left: indent, align(left, link(loc, it.indented(
      prefix,
      inner,
      gap: 0pt,
    )))),
    before: if chapter-entry and en-bachelor { bp(6) } else { 0pt },
  )
}

#let table-of-contents(config, depth: 3, title: auto, header: auto) = {
  special-chapter(
    if title == auto { chapter-names(config).contents } else { title },
    outlined: front-title-outlined(config, "contents"),
    header: header,
    kind: "contents",
  )
  fixed-line-start(before: if config.degree == "bachelor"
    and not chinese(config) { bp(6) } else { 0pt })
  show outline.entry: it => _toc-entry(config, it)
  set outline.entry(fill: dot-leader)
  outline(title: none, depth: depth, indent: 0pt)
}

#import "../config.typ": chapter-names, chinese, sans-fonts, serif-fonts
#import "../layouts/chapter-title.typ": chapter-label, render-title
#import "../layouts/runtime.typ": thuthesis-runtime
#import "common.typ": _front-title-outlined, _inside, _special-chapter
#import "../utils/text.typ": bp, tex-pt

#let _page-at(location) = {
  let matter = (thuthesis-runtime.matter-at)(location)
  let value = counter(page).at(location).first()
  numbering(if matter == "front" { "I" } else { "1" }, value)
}

// TeX's `titlerule*[4bp]{.}` advances by an invariant 4bp cell. Repeating
// a bare period plus a gap makes the pitch depend on the font's period
// advance and on Typst's justification of the leftover width.
#let _dot-leader-cell = box(width: bp(4), align(right, [.]))

#let _dot-leader = repeat(
  _dot-leader-cell,
  gap: 0pt,
  justify: false,
)

// LaTeX holds each fixed-baseline line open with a strut whose height/depth
// are 70%/30% of `baselineskip`. The page margin already contains TeX's
// `topskip` for ordinary 12bp text, so keep that portion as weak `above`
// spacing: it contributes in normal flow and disappears at a page boundary.
#let _fixed-line-block(
  body,
  size: bp(12),
  baseline: bp(20),
  before: 0pt,
) = {
  let page-top-skip = tex-pt(12) - 0.8 * size
  let top-inset = 0.7 * baseline - tex-pt(12)
  let bottom-inset = 0.3 * baseline - 0.2 * size
  block(
    above: page-top-skip + before,
    below: 0pt,
    width: 100%,
    breakable: false,
    inset: (top: top-inset, bottom: bottom-inset),
    body,
  )
}

// The first child of an outline has no preceding sibling, so its weak
// `above` spacing is discarded even though the outline itself follows a
// heading. Supply that portion once at the outline boundary.
#let _fixed-line-start(size: bp(12), before: 0pt) = v(
  tex-pt(12) - 0.8 * size + before,
  weak: false,
)

// ThuThesis's English graduate TOC uses `\heiti`: it changes only the CJK
// family, while Latin text stays in the surrounding serif family.
#let _toc-chapter-fonts(config) = if (
  not chinese(config) and config.degree != "bachelor"
) {
  (serif-fonts(config).first(),) + sans-fonts(config).slice(1)
} else {
  sans-fonts(config)
}

#let _toc-number(config, it) = context {
  let element = it.element
  if element.numbering == none {
    []
  } else {
    let location = element.location()
    let appendix = (thuthesis-runtime.appendix-at)(location)
    let values = counter(heading).at(location)
    if it.level == 1 {
      let number = numbering(if appendix { "A" } else { "1" }, values.first())
      chapter-label(config, number, appendix: appendix)
    } else {
      numbering(
        if appendix { "A.1.1.1" } else { element.numbering },
        ..values,
      )
    }
  }
}

#let _toc-gap(config) = if (
  (config.degree == "bachelor" and config.language == "chinese")
    or (config.degree != "bachelor" and config.language == "english")
) { text(" ") } else { h(1em) }

#let _toc-entry(env, it) = context {
  set par(first-line-indent: 0pt)
  let config = env.config
  let location = it.element.location()
  let source-matter = (thuthesis-runtime.matter-at)(location)
  if source-matter in ("appendix", "back") and it.level > 1 {
    none
  } else {
    let numbered = it.element.numbering != none
    let number = if numbered { _toc-number(config, it) } else { none }
    let indent = if not numbered {
      0pt
    } else if (
      config.degree == "bachelor" and config.language == "english"
    ) {
      (it.level - 1) * 0.5cm
    } else {
      (it.level - 1) * 1em
    }
    let chapter-entry = numbered and it.level == 1
    let chapter-before = if (
      chapter-entry
        and config.degree == "bachelor"
        and config.language == "english"
    ) { bp(6) } else { 0pt }
    let prefix = if numbered {
      let body = [#number#_toc-gap(config)]
      if chapter-entry {
        text(font: _toc-chapter-fonts(config), body)
      } else {
        body
      }
    } else { none }
    let outline-title = (thuthesis-runtime.heading-outline-at)(location)
    // Special chapters may use a distinct display and outline title.
    let title = if outline-title == auto { it.body() } else { outline-title }
    let title = if it.level == 1 {
      text(
        font: _toc-chapter-fonts(config),
        render-title(
          config,
          title,
          kind: (thuthesis-runtime.heading-kind-at)(location),
          target: "outline",
          numbered: numbered,
        ),
      )
    } else {
      title
    }
    let styled-inner = [#title#box(width: 1fr, it.fill)#text(
        font: serif-fonts(config),
        _page-at(location),
      )]
    let entry = it.indented(prefix, styled-inner, gap: 0pt)
    _fixed-line-block(
      pad(
        left: indent,
        align(left, link(location, entry)),
      ),
      before: chapter-before,
    )
  }
}

#let _table-of-contents(env, depth: 3, title: auto, header: auto) = _inside(
  env,
  config => {
    let names = chapter-names(config)
    _special-chapter(
      env,
      if title == auto { names.contents } else { title },
      outlined: _front-title-outlined(config, "contents"),
      header: header,
      kind: "contents",
    )
    _fixed-line-start(
      before: if config.degree == "bachelor"
        and config.language == "english" { bp(6) } else { 0pt },
    )
    show outline.entry: it => _toc-entry(env, it)
    set outline.entry(fill: _dot-leader)
    outline(
      title: none,
      depth: depth,
      indent: 0pt,
    )
  },
)

#import "../config.typ": chinese, is-graduate, sans-fonts
#import "body-size.typ": _body-baseline, _body-font-size, _body-top-skip
#import "chapter-title.typ": chapter-label, render-title
#import "runtime.typ": thuthesis-runtime
#import "../utils/text.typ": baseline-gap, bp, line-height, tex-pt, tex-vlist-boundary

// Apply a layout correction only when an unbreakable title block lands at
// a page boundary. In ordinary flow, the extra weak spacing and the strong
// inner correction cancel. At a page boundary Typst discards `above`, so
// the correction remains and moves both the title and following content.
#let _page-boundary-heading-block(above, below, correction, body) = block(
  above: above - correction,
  below: below,
  width: 100%,
  breakable: false,
  {
    v(correction, weak: false)
    block(above: 0pt, below: 0pt, width: 100%, body)
  },
)

// Return the first inert text run without laying out the paragraph a second
// time. It is real source content, while measuring the paragraph itself
// could duplicate citations, footnotes, counters, and contextual elements.
#let _first-inert-text(value) = if type(value) == str {
  text(value)
} else if type(value) == content {
  let fields = value.fields()
  if fields.at("text", default: none) != none {
    value
  } else {
    let children = fields.at("children", default: ())
    for child in children {
      let result = _first-inert-text(child)
      if result != none { return result }
    }
    let child = fields.at("child", default: none)
    if child != none { _first-inert-text(child) }
  }
}

// CTEX's heading `fixskip` leaves `\prevdepth` unset. TeX therefore places
// the following paragraph from its first real glyph ascent, whereas Typst's
// normal paragraph frame starts at 0.8em. Comparing those two measurements
// inherits the active font and size and introduces no coordinate constant.
#let _fixed-heading-boundary(body) = context v(
  measure(text(
    top-edge: "bounds",
    bottom-edge: "baseline",
    body,
  )).height
    - measure(text(
      top-edge: 0.8em,
      bottom-edge: "baseline",
      body,
    )).height,
  weak: false,
)

// Source-level heading declarations shared by every component. These are
// style rules from thuthesis.dtx, not coordinates of particular content.
#let _heading-rules = (
  body: (
    chapter: (before: bp(27), after: bp(27)),
    sections: (
      (before: bp(24), after: bp(6), alignment: left),
      (before: bp(12), after: bp(6), alignment: left),
      (before: bp(12), after: bp(6), alignment: left),
    ),
  ),
  committee: (
    chapter: (before: bp(27), after: bp(49), baseline: bp(20)),
    // The LaTeX regression output records `\glue(\lineskip) 1.0` between
    // each section heading and its surrounding multi-row tabulars.
    section: (
      before: bp(26),
      after: bp(9.5),
      alignment: center,
      before-interline: "lineskip",
      after-interline: "lineskip",
    ),
  ),
  authorization-graduate: (
    chapter: (
      before: bp(40),
      after: bp(36),
      size: bp(22),
      // thuthesis.dtx uses `\erhao`, whose default line-height multiplier
      // is 1.3: 22bp * 1.3 = 28.6bp.
      baseline: bp(22) * 1.3,
    ),
  ),
  authorization-bachelor: (
    chapter: (
      before: bp(40),
      after: bp(37),
      size: bp(22),
      baseline: bp(22) * 1.3,
    ),
  ),
  english-special: (
    chapter: (
      before: bp(27),
      after: bp(27),
      size: bp(16),
      baseline: bp(20),
      weight: "bold",
    ),
  ),
)

#let chapter-break(config, weak: true) = if (
  config.open-right and config.output == "print"
) {
  pagebreak(to: "odd", weak: weak)
} else {
  pagebreak(weak: weak)
}

#let _heading-number-at(it, appendix) = {
  let values = counter(heading).at(it.location())
  numbering(if appendix { "A" } else { "1" }, values.first())
}

// `thuthesis.dtx` sets `aftername = \quad` for every bachelor heading and
// for Chinese graduate headings. Only English graduate headings use
// `aftername = \space`. The TOC has a separate delimiter policy.
#let _heading-number-gap(config) = if (
  config.degree == "bachelor" or chinese(config)
) { h(1em) } else { text(" ") }

#let render-chapter-heading(
  config,
  it,
  before: auto,
  after: auto,
  baseline: auto,
  size: bp(16),
  weight: auto,
) = context {
  chapter-break(config)
  let numbered = it.numbering != none
  let location = it.location()
  let appendix = (thuthesis-runtime.appendix-at)(location)
  let number = if numbered { _heading-number-at(it, appendix) } else { none }
  let kind = (thuthesis-runtime.heading-kind-at)(location)
  let title = render-title(
    config,
    it.body,
    kind: kind,
    target: "heading",
    numbered: numbered,
  )
  let body = {
    if numbered {
      chapter-label(config, number, appendix: appendix)
      _heading-number-gap(config)
    }
    title
  }
  let baseline = if baseline == auto {
    // The corresponding CTEX format uses bare `\sanhao`, so its 16bp size
    // retains the named-size default 1.3 line-height multiplier.
    if chinese(config) or config.degree == "bachelor" { size * 1.3 } else {
      bp(20)
    }
  } else { baseline }
  let weight = if weight == auto {
    if chinese(config) or (kind == "statement" and is-graduate(config)) {
      "regular"
    } else { "bold" }
  } else { weight }
  let rules = _heading-rules.body.chapter
  let before = if before == auto { rules.before } else { before }
  let after = if after == auto { rules.after } else { after }
  // `block.above` is weak spacing and disappears after the chapter page break.
  // CTEX's `fixskip` retains the chapter beforeskip at the page top and
  // subtracts TeX's `\topskip`.
  v(before - _body-top-skip, weak: false)
  // Center each line of an English chapter title at its natural width.
  set par(justify: false) if not chinese(config)
  block(
    above: 0pt,
    below: after,
    width: 100%,
    breakable: false,
    align(center, line-height(
      size,
      baseline,
      text(
        font: sans-fonts(config),
        weight: weight,
        // A TeX heading box is bounded by its glyphs, not by the generic
        // 0.8em/0.2em body strut. This also derives the former sub-point
        // before/after-heading compensation from the selected font.
        top-edge: "bounds",
        bottom-edge: "bounds",
        body,
      ),
    )),
  )
  (thuthesis-runtime.mark-after-heading)("chapter")
}

#let _section-heading(
  config,
  it,
  before: auto,
  after: auto,
  alignment: left,
  frame-spacing: false,
  size: auto,
  suffix: none,
  before-interline: "auto",
  after-interline: "auto",
) = context {
  let sizes = (bp(14), bp(13), bp(12))
  let idx = calc.min(it.level - 2, 2)
  let size = if size == auto { sizes.at(idx) } else { size }
  let rules = _heading-rules.body.sections.at(idx)
  let before = if before == auto { rules.before } else { before }
  let after = if after == auto { rules.after } else { after }
  let previous-heading = (thuthesis-runtime.after-heading-at)(it.location())
  let follows-chapter = (
    previous-heading != none and previous-heading.kind == "chapter"
  )
  let appendix = (thuthesis-runtime.appendix-at)(it.location())
  let number = if it.numbering != none {
    let values = counter(heading).at(it.location())
    numbering(if appendix { "A.1.1.1" } else { it.numbering }, ..values)
  } else { none }
  let body = {
    if number != none {
      number
      _heading-number-gap(config)
    }
    it.body
    if suffix != none { suffix }
  }
  let heading-text = text(
    font: sans-fonts(config),
    weight: if chinese(config) { "regular" } else { "bold" },
    body,
  )
  let framed-boundary = (
    frame-spacing or before-interline != "auto" or after-interline != "auto"
  )
  let natural-ascent = if framed-boundary {
    measure(text(
      size: size,
      top-edge: "bounds",
      bottom-edge: "baseline",
      heading-text,
    )).height
  } else { 0pt }
  let natural-depth = if framed-boundary {
    measure(text(
      size: size,
      top-edge: 0em,
      bottom-edge: "bounds",
      heading-text,
    )).height
  } else { 0pt }
  let before-boundary = if follows-chapter or not framed-boundary {
    none
  } else if before-interline == "lineskip" {
    // The neighboring box cancels out of the edge-to-edge result once TeX
    // has selected `lineskip`; zero is therefore the neutral value here.
    tex-vlist-boundary(
      _body-baseline,
      0pt,
      natural-ascent,
      skip: before,
      next-frame-height: 0.8 * size,
      mode: "lineskip",
    )
  } else {
    tex-vlist-boundary(
      _body-baseline,
      0.2 * _body-font-size,
      natural-ascent,
      skip: before,
      next-frame-height: 0.8 * size,
    )
  }
  let before = if follows-chapter {
    0pt
  } else if before-boundary != none {
    before-boundary.spacing
  } else { before }
  let source-after = after
  let after = if not framed-boundary {
    after
  } else if after-interline == "lineskip" {
    tex-vlist-boundary(
      _body-baseline,
      natural-depth,
      0pt,
      skip: after,
      previous-frame-depth: 0.2 * size,
      mode: "lineskip",
    ).spacing
  } else {
    tex-vlist-boundary(
      _body-baseline,
      natural-depth,
      0.8 * _body-font-size,
      skip: after,
      previous-frame-depth: 0.2 * size,
    ).spacing
  }
  // The page margin carries the top-skip remainder for a 12bp body line.
  // A heading that becomes the first box on a page therefore needs the
  // difference between the canonical body ascent and its own line-frame
  // ascent. Keep that correction inside the block and add its inverse to
  // the weak `above` spacing through `_page-boundary-heading-block`.
  // A section immediately following a chapter is already inside that
  // chapter's page. Applying the page-boundary cancellation there would
  // leave its inner shift behind when the two blocks' spacing collapses.
  let page-start-correction = if (
    before-interline == "lineskip"
      or (
        before-boundary != none and before-boundary.uses-lineskip
      )
  ) {
    natural-ascent - 0.8 * size
  } else if follows-chapter {
    0pt
  } else {
    0.8 * (_body-font-size - size)
  }
  _page-boundary-heading-block(
    before,
    after,
    page-start-correction,
    align(alignment, line-height(size, bp(20), heading-text)),
  )
  // TeX adds a section's afterskip and a following float's `\intextsep`.
  // Typst collapses the two block spacings, so retain the source-derived
  // difference until either a figure or an intervening paragraph appears.
  let figure-correction = if framed-boundary {
    (
      natural-depth
        + source-after
        + tex-pt(12)
        - 0.2 * size
        - calc.max(after, tex-pt(12))
    )
  } else { 0pt }
  (thuthesis-runtime.mark-after-heading)(
    "section",
    figure-correction: figure-correction,
  )
}

// Counter mutation belongs to the numbered-chapter boundary. Heading renderers
// only read the number and semantic state at the source heading.
#let _numbered-chapter-boundary(config, it, body) = {
  if it.numbering != none {
    if config.figure-numbering == "chapter" {
      counter(figure.where(kind: image)).update(0)
    }
    if config.table-numbering == "chapter" {
      counter(figure.where(kind: table)).update(0)
    }
    if config.equation-numbering == "chapter" {
      counter(math.equation).update(0)
    }
    if config.footnote-numbering == "chapter" { counter(footnote).update(0) }
  }
  body
}

#let _chapter-heading(config, it, ..options) = _numbered-chapter-boundary(
  config,
  it,
  render-chapter-heading(config, it, ..options),
)

// Central heading renderer. Components select a semantic variant; they do not
// position individual headings.
#let heading-style(config, body, variant: "body") = {
  assert(
    variant
      in (
        "body",
        "committee",
        "authorization-graduate",
        "authorization-bachelor",
        "english-special",
        "resume",
      ),
    message: "thuthesis: invalid heading style variant",
  )
  set heading(numbering: "1.1.1.1", outlined: true)
  if variant == "committee" {
    let rules = _heading-rules.committee
    show heading.where(level: 1): it => _chapter-heading(
      config,
      it,
      ..rules.chapter,
    )
    show heading.where(level: 2): it => _section-heading(
      config,
      it,
      ..rules.section,
    )
    body
  } else if variant == "body" {
    show heading.where(level: 1): it => _chapter-heading(config, it)
    show heading.where(level: 2): it => _section-heading(
      config,
      it,
      frame-spacing: true,
    )
    show heading.where(level: 3): it => _section-heading(
      config,
      it,
      frame-spacing: true,
    )
    show heading.where(level: 4): it => _section-heading(
      config,
      it,
      frame-spacing: true,
    )
    body
  } else if variant == "resume" {
    show heading.where(level: 2): it => _section-heading(
      config,
      it,
      alignment: if config.degree == "bachelor" { left } else { center },
      frame-spacing: true,
      suffix: if config.degree == "bachelor" { [：] } else { none },
    )
    show heading.where(level: 3): it => _section-heading(
      config,
      it,
      before: if chinese(config) { bp(12) } else { 0pt },
      after: baseline-gap(
        if chinese(config) { bp(6) } else { 0pt },
        if chinese(config) { bp(14) } else { bp(13) },
        if not chinese(config) and config.degree == "bachelor" {
          bp(15)
        } else { bp(12) },
        if chinese(config) and config.degree != "bachelor" { bp(16) } else {
          bp(20)
        },
      ),
      size: if chinese(config) { bp(14) } else { auto },
      suffix: if chinese(config) { [：] } else { none },
    )
    body
  } else {
    let rules = _heading-rules.at(variant)
    show heading.where(level: 1): it => _chapter-heading(
      config,
      it,
      ..rules.chapter,
    )
    body
  }
}

#import "../config.typ": chinese, is-graduate
#import "chapter-title.typ": chapter-label, render-title
#import "runtime.typ": mark-after-heading, runtime-at
#import "../utils/text.typ": (
  body-baseline, body-font-size, body-top-skip, bp, ink-ascent, ink-descent,
  line-height, tex-glue, tex-pt,
)

// Apply a layout correction only when an unbreakable title block lands at a page top.
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

// Extract the first plain text leaf without laying out the paragraph twice.
#let first-inert-text(value) = if type(value) == content {
  let fields = value.fields()
  if fields.at("text", default: none) != none {
    value
  } else {
    for child in fields.at("children", default: ()) {
      let result = first-inert-text(child)
      if result != none { return result }
    }
    let child = fields.at("child", default: none)
    if child != none { first-inert-text(child) }
  }
}

// Restore CTEX `fixskip` natural first-line ascent after a heading boundary.
#let fixed-heading-boundary(body) = context v(
  ink-ascent(body)
    - measure(text(top-edge: 0.8em, bottom-edge: "baseline", body)).height,
  weak: false,
)

#let _section-defaults = (
  (before: bp(24), after: bp(6)),
  (before: bp(12), after: bp(6)),
  (before: bp(12), after: bp(6)),
)

#let _chapter-variants = (
  committee: (after: bp(49), baseline: bp(20)),
  authorization-graduate: (
    before: bp(40),
    after: bp(36),
    size: bp(22),
    baseline: bp(22) * 1.3,
  ),
  authorization-bachelor: (
    before: bp(40),
    after: bp(37),
    size: bp(22),
    baseline: bp(22) * 1.3,
  ),
  english-special: (baseline: bp(20), weight: "bold"),
)

#let heading-number-at(it, appendix) = {
  let values = counter(heading).at(it.location())
  numbering(if appendix { "A" } else { "1" }, values.first())
}

// `aftername = \quad` for bachelor and Chinese graduate headings; `\space` for English graduate.
#let heading-number-gap(config) = if (
  config.degree == "bachelor" or chinese(config)
) { h(1em) } else { text(" ") }

#let _chapter-heading(
  config,
  it,
  before: bp(27),
  after: bp(27),
  baseline: auto,
  size: bp(16),
  weight: auto,
) = {
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
  context {
    if config.open-right and config.output == "print" {
      pagebreak(to: "odd", weak: true)
    } else {
      pagebreak(weak: true)
    }
    let numbered = it.numbering != none
    let state = runtime-at(it.location())
    let appendix = state.matter == "appendix"
    let title = render-title(
      config,
      it.body,
      kind: state.heading-kind,
      numbered: numbered,
    )
    let body = {
      if numbered {
        chapter-label(
          config,
          heading-number-at(it, appendix),
          appendix: appendix,
        )
        heading-number-gap(config)
      }
      title
    }
    let baseline = if baseline == auto {
      if chinese(config) or config.degree == "bachelor" { size * 1.3 } else {
        bp(20)
      }
    } else { baseline }
    let weight = if weight == auto {
      if (
        chinese(config)
          or (state.heading-kind == "statement" and is-graduate(config))
      ) { "regular" } else { "bold" }
    } else { weight }
    v(before - body-top-skip, weak: false)
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
          font: config.fonts.HeiTi,
          weight: weight,
          top-edge: "bounds",
          bottom-edge: "bounds",
          body,
        ),
      )),
    )
    mark-after-heading("chapter")
  }
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
  lineskip: false,
) = context {
  let idx = calc.min(it.level - 2, 2)
  let size = if size == auto { (bp(14), bp(13), bp(12)).at(idx) } else { size }
  let rules = _section-defaults.at(idx)
  let source-before = if before == auto { rules.before } else { before }
  let source-after = if after == auto { rules.after } else { after }
  let state = runtime-at(it.location())
  let follows-chapter = (
    state.after-heading != none and state.after-heading.kind == "chapter"
  )
  let body = {
    if it.numbering != none {
      let values = counter(heading).at(it.location())
      numbering(
        if state.matter == "appendix" { "A.1.1.1" } else { it.numbering },
        ..values,
      )
      heading-number-gap(config)
    }
    it.body
    if suffix != none { suffix }
  }
  let heading-text = text(
    font: config.fonts.HeiTi,
    weight: if chinese(config) { "regular" } else { "bold" },
    body,
  )
  let framed = frame-spacing or lineskip
  let natural-ascent = if framed {
    ink-ascent(text(size: size, heading-text))
  } else { 0pt }
  let natural-depth = if framed {
    ink-descent(text(size: size, heading-text))
  } else { 0pt }
  let before-gap = if lineskip { tex-pt(1) } else {
    tex-glue(body-baseline, 0.2 * body-font-size, natural-ascent)
  }
  let before-lineskip = (
    lineskip
      or (
        framed
          and not follows-chapter
          and body-baseline - 0.2 * body-font-size - natural-ascent < 0pt
      )
  )
  let before = if follows-chapter {
    0pt
  } else if framed {
    source-before + before-gap + natural-ascent - 0.8 * size
  } else {
    source-before
  }
  let after-gap = if lineskip { tex-pt(1) } else {
    tex-glue(body-baseline, natural-depth, 0.8 * body-font-size)
  }
  let after = if framed {
    source-after + natural-depth + after-gap - 0.2 * size
  } else { source-after }
  let page-start-correction = if before-lineskip {
    natural-ascent - 0.8 * size
  } else if follows-chapter {
    0pt
  } else {
    0.8 * (body-font-size - size)
  }
  _page-boundary-heading-block(
    before,
    after,
    page-start-correction,
    align(alignment, line-height(size, bp(20), heading-text)),
  )
  // Retain TeX's additive section-afterskip + float `\intextsep` difference.
  let figure-correction = if framed {
    (
      natural-depth
        + source-after
        + tex-pt(12)
        - 0.2 * size
        - calc.max(after, tex-pt(12))
    )
  } else { 0pt }
  mark-after-heading("section", figure-correction: figure-correction)
}

#let _heading-ref(config, it) = {
  let el = it.element
  if (
    el == none
      or el.func() != heading
      or el.numbering == none
      or it.form != "normal"
      or it.supplement != auto
  ) {
    return it
  }
  context {
    let loc = el.location()
    let appendix = runtime-at(loc).matter == "appendix"
    let values = counter(heading).at(loc)
    let zh = chinese(config)
    let label = if el.level == 1 {
      let number = numbering(if appendix { "A" } else { "1" }, values.first())
      if appendix {
        if zh [附录~#number] else [Appendix~#number]
      } else if zh {
        [第~#number~章]
      } else {
        [Chapter~#number]
      }
    } else {
      let number = numbering(
        if appendix { "A.1.1.1" } else { el.numbering },
        ..values,
      )
      if zh {
        [第~#number~节]
      } else {
        [Section~#number]
      }
    }
    link(loc, label)
  }
}

#let heading-style(config, body, variant: "body") = {
  set heading(numbering: "1.1.1.1", outlined: true)
  if variant == "committee" {
    show heading.where(level: 1): it => _chapter-heading(
      config,
      it,
      .._chapter-variants.committee,
    )
    show heading.where(level: 2): it => _section-heading(
      config,
      it,
      before: bp(26),
      after: bp(9.5),
      alignment: center,
      lineskip: true,
    )
    body
  } else if variant == "body" {
    show ref: it => _heading-ref(config, it)
    show heading.where(level: 1): it => _chapter-heading(config, it)
    show heading
      .where(level: 2)
      .or(
        heading.where(level: 3),
        heading.where(level: 4),
      ): it => _section-heading(
      config,
      it,
      frame-spacing: true,
    )
    body
  } else if variant == "resume" {
    let zh = chinese(config)
    show heading.where(level: 2): it => _section-heading(
      config,
      it,
      alignment: if config.degree == "bachelor" { left } else { center },
      frame-spacing: true,
      suffix: if config.degree == "bachelor" { [：] } else { none },
    )
    show heading.where(level: 3): it => {
      let from-size = if zh { bp(14) } else { bp(13) }
      let to-size = if not zh and config.degree == "bachelor" { bp(15) } else {
        bp(12)
      }
      let base = if zh and config.degree != "bachelor" { bp(16) } else {
        bp(20)
      }
      _section-heading(
        config,
        it,
        before: if zh { bp(12) } else { 0pt },
        after: base
          + (if zh { bp(6) } else { 0pt })
          - 0.2 * from-size
          - 0.8 * to-size,
        size: if zh { bp(14) } else { auto },
        suffix: if zh { [：] } else { none },
      )
    }
    body
  } else {
    show heading.where(level: 1): it => _chapter-heading(
      config,
      it,
      .._chapter-variants.at(variant),
    )
    body
  }
}

// Text measurement and distribution primitives.

// Typst's point is 1/72 inch and is physically equal to TeX's bp. Values
// written as TeX pt in thuthesis.dtx must use tex-pt instead.
#let bp(value) = value * 1pt
#let tex-pt(value) = value * 1in / 72.27

#let plain-text(value, default: none) = if type(value) == str {
  value
} else if type(value) == content {
  value.fields().at("text", default: default)
} else {
  default
}

#let line-height(size, baseline, body, paragraph-spacing: none) = {
  set text(size: size, top-edge: 0.8em, bottom-edge: -0.2em)
  set par(
    leading: baseline - size,
    spacing: if paragraph-spacing == none { baseline - size } else {
      paragraph-spacing
    },
  )
  body
}

#let baseline-gap(
  skip,
  from-size,
  to-size,
  baseline,
  top-edge: 0.8,
  bottom-edge: 0.2,
) = baseline + skip - bottom-edge * from-size - top-edge * to-size

// Measure the maximum ink above the baseline in the component's real text.
// Suppressing explicit line breaks prevents their interline space from
// becoming part of this glyph metric.
#let content-ink-ascent(body) = {
  measure({
    show linebreak: it => none
    set text(top-edge: "bounds", bottom-edge: "baseline")
    body
  }).height
}

// TeX appends every line box to a vertical list with the same rule. It
// normally preserves `baseline`, but switches to `lineskip` when the
// natural depth and height of two adjacent boxes leave less than
// `lineskip-limit`. Convert that baseline-oriented result to the edge gap
// required by Typst's block flow. The natural and frame edges differ when
// a Typst line uses an explicit 0.8em/0.2em frame around real glyph bounds.
#let tex-vlist-boundary(
  baseline,
  previous-depth,
  next-height,
  skip: 0pt,
  previous-frame-depth: auto,
  next-frame-height: auto,
  lineskip: tex-pt(1),
  lineskip-limit: 0pt,
  mode: "auto",
) = {
  assert(mode in ("auto", "lineskip"))
  let previous-frame-depth = if previous-frame-depth == auto {
    previous-depth
  } else { previous-frame-depth }
  let next-frame-height = if next-frame-height == auto {
    next-height
  } else { next-frame-height }
  let normal = baseline - previous-depth - next-height
  let uses-lineskip = mode == "lineskip" or normal < lineskip-limit
  let interline = if uses-lineskip { lineskip } else { normal }
  (
    spacing: (
      skip
        + previous-depth
        + interline
        + next-height
        - previous-frame-depth
        - next-frame-height
    ),
    uses-lineskip: uses-lineskip,
  )
}

#let _characters(value) = if type(value) == str {
  value.clusters()
} else {
  assert(
    type(value) == array,
    message: "thuthesis: distributed text must be a string or an explicit character array",
  )
  for item in value {
    assert(
      type(item) in (str, content),
      message: "thuthesis: explicit character data must contain strings or content",
    )
  }
  value
}

#let distribute(width, value, shrink: false) = context {
  let characters = _characters(value)
  let body = characters.join()
  let resolved-width = measure(box(width: width)).width
  if characters.len() <= 1 {
    box(width: width, align(center, body))
  } else {
    let natural = measure(body).width
    let gap = (resolved-width - natural) / (characters.len() - 1)
    let gap = if shrink { gap } else { calc.max(0pt, gap) }
    box(width: width, {
      set par(first-line-indent: 0pt)
      for (index, character) in characters.enumerate() {
        character
        if index < characters.len() - 1 { h(gap) }
      }
    })
  }
}

#let stretch(width, value) = context {
  let characters = _characters(value)
  let body = characters.join()
  let resolved-width = measure(box(width: width)).width
  if measure(body).width < resolved-width {
    distribute(width, characters)
  } else {
    body
  }
}

// Simple markup text can safely become character data. Richly styled content
// remains intact and is not silently flattened.
#let stretch-text(width, value) = {
  let source = plain-text(value)
  if source == none { value } else { stretch(width, source) }
}

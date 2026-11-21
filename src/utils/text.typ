// Text measurement, TeX vertical-list helpers, and CJK distribution primitives.

// Typst's pt equals TeX's bp (1/72 in); TeX pt is 1/72.27 in.
#let bp(value) = value * 1pt
#let tex-pt(value) = value * 1in / 72.27

#let body-font-size = bp(12)
#let body-baseline = bp(20)
// TeX's `\topskip` (12pt) minus Typst's 0.8em top-edge frame.
#let body-top-skip = tex-pt(12) - 0.8 * body-font-size

#let plain-text(value) = if type(value) == str {
  value
} else if type(value) == content {
  value.fields().at("text", default: none)
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

#let ink-ascent(body) = {
  measure({
    show linebreak: it => none
    set text(top-edge: "bounds", bottom-edge: "baseline")
    body
  }).height
}

#let ink-descent(body) = {
  measure({
    set text(top-edge: 0em, bottom-edge: "bounds")
    body
  }).height
}

// LaTeX's `\strutbox` splits a row baseline into 70% ascent / 30% depth.
#let array-inset(size, baseline) = (
  x: tex-pt(6),
  top: 0.7 * baseline - 0.8 * size,
  bottom: 0.3 * baseline - 0.2 * size,
)

#let array-cell(size, baseline, body) = pad(
  top: 0.7 * baseline - 0.8 * size,
  bottom: 0.3 * baseline - 0.2 * size,
  body,
)

// TeX interline glue with `\lineskiplimit = 0pt` and `\lineskip = 1pt`.
#let tex-glue(baseline, prev-depth, next-height) = {
  let g = baseline - prev-depth - next-height
  if g < 0pt { tex-pt(1) } else { g }
}

#let distribute(width, value, shrink: false) = context {
  let chars = if type(value) == str { value.clusters() } else { value }
  let body = chars.join()
  let resolved = measure(box(width: width)).width
  if chars.len() <= 1 {
    box(width: width, align(center, body))
  } else {
    let gap = (resolved - measure(body).width) / (chars.len() - 1)
    let gap = if shrink { gap } else { calc.max(0pt, gap) }
    box(width: width, {
      set par(first-line-indent: 0pt)
      chars.join(h(gap))
    })
  }
}

#let stretch(width, value) = context {
  if measure(value).width < measure(box(width: width)).width {
    distribute(width, value)
  } else {
    value
  }
}

#let stretch-text(width, value) = {
  let source = plain-text(value)
  if source == none { value } else { stretch(width, source) }
}

#import "../config.typ": chinese
#import "figures.typ": object-number
#import "../utils/text.typ": body-baseline, body-font-size, bp, tex-glue

#let _non-tex-math-style(style, body) = {
  // XITS Math StylisticSet=8 selects upright integrals (matching XeLaTeX).
  show math.equation: set text(stylistic-set: 8)
  show regex("[Α-ΡΣ-ΩϜϴ]"): math.italic
  show math.partial: math.upright
  show math.dots: if style == "GB" { math.dots.h.c } else { math.dots.h }
  show math.Re: math.upright("Re")
  show math.Im: math.upright("Im")
  if style == "GB" {
    show sym.lt.eq: sym.lt.eq.slant
    show sym.gt.eq: sym.gt.eq.slant
    body
  } else {
    show regex(
      "[\u{222b}-\u{2233}\u{2a0b}-\u{2a0f}\u{2a11}\u{2a16}-\u{2a1a}]",
    ): math.limits.with(inline: false)
    body
  }
}

#let _display-equation(it) = context {
  // Split Typst's centered equation frame at XITS Math's 0.25em math axis
  // before applying TeX's baselineskip/lineskip rule plus 6bp display skip.
  set block(above: 0pt, below: 0pt)
  let h = measure(it).height
  let axis = body-font-size / 4
  let above = (
    bp(6) + tex-glue(body-baseline, 0.2 * body-font-size, h / 2 + axis)
  )
  let below = (
    bp(6) + tex-glue(body-baseline, h / 2 - axis, 0.8 * body-font-size)
  )
  block(above: 0pt, below: 0pt, {
    v(above, weak: false)
    it
    v(below, weak: false)
  })
}

#let equation-style(config, body) = {
  show math.equation: set text(font: config.fonts.Math)
  set math.equation(numbering: n => {
    let number = object-number(
      config.equation-numbering,
      config.equation-number-separator,
      n,
    )
    let label = if chinese(config) and config.eqn-paren-style == "full" {
      [（#number）]
    } else { [(#number)] }
    text(font: config.fonts.SongTi, label)
  })
  show math.equation.where(block: true): _display-equation
  if config.math-style == "TeX" { body } else {
    _non-tex-math-style(config.math-style, body)
  }
}

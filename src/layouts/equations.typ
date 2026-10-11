#import "../config.typ": chinese, math-fonts, serif-fonts
#import "body-size.typ": _body-baseline, _body-font-size
#import "figures.typ": _object-number
#import "../utils/text.typ": bp, tex-vlist-boundary

// thuthesis.dtx's GB and ISO styles differ from Typst's TeX-oriented
// defaults in these symbols. Keep all rules in one scope: a nested show-rule
// helper would realize the formula before an outer symbol rule sees it.
#let _non-tex-math-style(style, body) = {
  // The LaTeX XITS setup selects StylisticSet=8 for upright integrals. All
  // built-in font profiles use XITS Math, as required by this feature.
  show math.equation: set text(stylistic-set: 8)
  show math.Alpha: math.italic
  show math.Beta: math.italic
  show math.Digamma: math.italic
  show math.Gamma: math.italic
  show math.Delta: math.italic
  show math.Epsilon: math.italic
  show math.Zeta: math.italic
  show math.Eta: math.italic
  show math.Theta: math.italic
  show math.Theta.alt: math.italic
  show math.Iota: math.italic
  show math.Kappa: math.italic
  show math.Lambda: math.italic
  show math.Mu: math.italic
  show math.Nu: math.italic
  show math.Xi: math.italic
  show math.Omicron: math.italic
  show math.Pi: math.italic
  show math.Rho: math.italic
  show math.Sigma: math.italic
  show math.Tau: math.italic
  show math.Upsilon: math.italic
  show math.Phi: math.italic
  show math.Chi: math.italic
  show math.Psi: math.italic
  show math.Omega: math.italic
  let less-than-or-equal = if style == "GB" {
    sym.lt.eq.slant
  } else { it => it }
  let greater-than-or-equal = if style == "GB" {
    sym.gt.eq.slant
  } else { it => it }
  let ellipsis = if style == "GB" { math.dots.h.c } else { math.dots.h }
  let integral-limits = if style == "ISO" {
    math.limits.with(inline: false)
  } else { it => it }
  show sym.lt.eq: less-than-or-equal
  show sym.gt.eq: greater-than-or-equal
  show math.partial: math.upright
  show math.dots: ellipsis
  show math.Re: math.upright("Re")
  show math.Im: math.upright("Im")
  show math.integral: integral-limits
  show math.integral.arrow.hook: integral-limits
  show math.integral.ccw: integral-limits
  show math.integral.cont: integral-limits
  show math.integral.cont.ccw: integral-limits
  show math.integral.cont.cw: integral-limits
  show math.integral.cw: integral-limits
  show math.integral.dash: integral-limits
  show math.integral.dash.double: integral-limits
  show math.integral.double: integral-limits
  show math.integral.quad: integral-limits
  show math.integral.inter: integral-limits
  show math.integral.slash: integral-limits
  show math.integral.square: integral-limits
  show math.integral.surf: integral-limits
  show math.integral.times: integral-limits
  show math.integral.triple: integral-limits
  show math.integral.union: integral-limits
  show math.integral.vol: integral-limits
  show math.sum.integral: integral-limits
  body
}

#let _display-equation(config, it) = context {
  // Typst exposes an equation as a centered frame, while TeX appends a box
  // whose baseline lies on the OpenType math axis. XITS MATH's AxisHeight is
  // 0.25em, so split the measured frame at that axis before applying TeX's
  // normal baselineskip/lineskip decision to each boundary.
  set block(above: 0pt, below: 0pt)
  let formula-height = measure(it).height
  let math-axis = _body-font-size / 4
  let formula-ascent = formula-height / 2 + math-axis
  let formula-depth = formula-height / 2 - math-axis
  // The equation show rule cannot inspect the adjacent laid-out paragraph
  // lines. Use the document's declared line frame on both boundaries rather
  // than substituting a language-specific representative glyph.
  let above = tex-vlist-boundary(
    _body-baseline,
    0.2 * _body-font-size,
    formula-ascent,
    skip: bp(6),
    previous-frame-depth: 0.2 * _body-font-size,
    next-frame-height: formula-ascent,
  ).spacing
  let below = tex-vlist-boundary(
    _body-baseline,
    formula-depth,
    0.8 * _body-font-size,
    skip: bp(6),
    previous-frame-depth: formula-depth,
    next-frame-height: 0.8 * _body-font-size,
  ).spacing
  // TeX appends display glue in addition to surrounding vertical-list glue.
  // Put it inside a zero-spacing wrapper so Typst does not collapse it with
  // an adjacent figure's `below` spacing.
  block(above: 0pt, below: 0pt, {
    v(above, weak: false)
    it
    v(below, weak: false)
  })
}

#let _equation-style(config, body) = {
  show math.equation: set text(font: math-fonts(config))
  set math.equation(numbering: n => {
    let number = _object-number(
      config,
      config.equation-numbering,
      config.equation-number-separator,
      n,
    )
    if chinese(config) and config.eqn-paren-style == "full" {
      text(font: serif-fonts(config), [（#number）])
    } else {
      text(font: serif-fonts(config), [(#number)])
    }
  })
  show math.equation.where(block: true): it => _display-equation(config, it)
  if config.math-style == "TeX" { body } else {
    _non-tex-math-style(config.math-style, body)
  }
}

#import "../config.typ": chinese, mono-fonts, serif-fonts
#import "body-size.typ": _body-baseline, _body-font-size
#import "equations.typ": _equation-style
#import "figures.typ": _figure-style, _subfigure-style
#import "footnotes.typ": _footnote-style
#import "headings.typ": _first-inert-text, _fixed-heading-boundary, heading-style
#import "runtime.typ": thuthesis-runtime
#import "../utils/util.typ": show-latexref
#import "../utils/text.typ": tex-pt

#let _compatibility-style(config, body) = {
  if config.use-latexref { show-latexref(config.latexref-prefixes, body) } else {
    body
  }
}

#let _compatibility-options(config, body) = {
  if config.unnumbered-label not in (none, "") {
    show math.equation.where(label: label(
      config.unnumbered-label,
    )): set math.equation(
      numbering: none,
    )
  }
  if config.use-fakebold {
    // Typst exposes synthetic strokes at the text layer. Restricting this
    // compatibility opt-in to strong text avoids altering regular body ink.
    show strong: set text(stroke: 0.015em)
  }
  body
}

#let _body-style(config, body) = {
  set text(
    font: serif-fonts(config),
    size: _body-font-size,
    top-edge: 0.8em,
    bottom-edge: -0.2em,
    lang: if chinese(config) { "zh" } else { "en" },
    region: if chinese(config) { "CN" } else { none },
    // TeX uses finite widow and club penalties, while Typst currently
    // treats every non-zero cost as an absolute prohibition. Let the
    // available page height decide so two-line paragraphs can split like
    // their LaTeX counterparts when a footnote occupies the page bottom.
    costs: (widow: 0%, orphan: 0%),
  )
  set par(
    justify: true,
    // Typst's optimized breaker matches TeX's paragraph-wide algorithm for
    // English. For Chinese prose, the simple breaker follows xeCJK's dense
    // per-character opportunities more closely and avoids unstable reshaping.
    linebreaks: if chinese(config) { "simple" } else { "optimized" },
    leading: _body-baseline - _body-font-size,
    spacing: _body-baseline - _body-font-size,
    first-line-indent: (
      amount: if chinese(config) { 2em } else if config.degree == "bachelor" {
        0.8cm
      } else { 0.74cm },
      all: true,
    ),
  )
  // A real paragraph ends chapter/section adjacency before the next heading
  // rule is evaluated. At that same boundary, restore CTEX's natural first
  // line ascent without changing the paragraph's internal line frames.
  show par: it => context {
    let boundary = (thuthesis-runtime.after-heading-at)(it.location())
    (thuthesis-runtime.clear-after-heading)()
    if boundary != none {
      let first-text = _first-inert-text(it.body)
      if first-text != none { _fixed-heading-boundary(first-text) }
    }
    it
  }
  // The 12pt book layout fixes first-level `leftmargin` at 30pt and
  // `labelsep` at 6pt. LaTeX right-aligns the marker in the remaining 24pt
  // `labelwidth`; measuring a marker only detects the exceptional case in
  // which it overflows that slot. Ordinary markers never move the body.
  let label-separation = tex-pt(6)
  let label = body => box(
    width: tex-pt(30) - label-separation,
    align(right, body),
  )
  // Typst measures `spacing` between item boxes, while LaTeX's zero
  // `itemsep` still retains the document baseline. One leading restores
  // that baseline without adding an extra blank line between items.
  set list(
    marker: label(sym.bullet),
    indent: 0pt,
    body-indent: label-separation,
    spacing: _body-baseline - _body-font-size,
  )
  set enum(
    numbering: n => label(numbering("1.", n)),
    indent: 0pt,
    body-indent: label-separation,
    spacing: _body-baseline - _body-font-size,
  )
  // TeX arrays hold a 20bp body row open with a 14bp/6bp strut. Preserve
  // that asymmetric baseline instead of splitting the 8bp allowance evenly.
  set table(inset: (
    x: tex-pt(6),
    top: 0.7 * _body-baseline - 0.8 * _body-font-size,
    bottom: 0.3 * _body-baseline - 0.2 * _body-font-size,
  ))
  show raw: set text(font: mono-fonts(config))
  let styles = (
    _figure-style,
    _equation-style,
    _footnote-style,
    heading-style,
    _subfigure-style,
    _compatibility-style,
    _compatibility-options,
  )
  styles.fold(body, (result, style) => style(config, result))
}

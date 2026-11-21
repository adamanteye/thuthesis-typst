#import "../config.typ": chinese
#import "equations.typ": equation-style
#import "figures.typ": figure-style, subfigure-style
#import "footnotes.typ": footnote-style
#import "headings.typ": first-inert-text, fixed-heading-boundary, heading-style
#import "page.typ": page-set
#import "runtime.typ": clear-after-heading, runtime-at
#import "../utils/text.typ": array-inset, body-baseline, body-font-size, tex-pt
#import "../utils/util.typ": show-latexref

#let document-meta(config, body) = {
  set document(
    title: config.metadata.title,
    author: if config.anonymous { () } else { (config.metadata.author,) },
    description: config.metadata.subject,
  )
  set text(fallback: false, costs: (hyphenation: 25%), overhang: false)
  body
}

#let _body-style(config, body) = {
  let zh = chinese(config)
  let leading = body-baseline - body-font-size
  set text(
    font: config.fonts.SongTi,
    size: body-font-size,
    top-edge: 0.8em,
    bottom-edge: -0.2em,
    lang: if zh { "zh" } else { "en" },
    region: if zh { "CN" } else { none },
    costs: (widow: 0%, orphan: 0%),
  )
  set par(
    justify: true,
    linebreaks: if zh { "simple" } else { "optimized" },
    leading: leading,
    spacing: leading,
    first-line-indent: (
      amount: if zh { 2em } else if config.degree == "bachelor" { 0.8cm } else {
        0.74cm
      },
      all: true,
    ),
  )
  show par: it => context {
    let boundary = runtime-at(it.location()).after-heading
    clear-after-heading()
    if boundary != none {
      let first-text = first-inert-text(it.body)
      if first-text != none { fixed-heading-boundary(first-text) }
    }
    it
  }
  let label-sep = tex-pt(6)
  let marker(content) = box(width: tex-pt(30) - label-sep, align(
    right,
    content,
  ))
  set list(
    marker: marker(sym.bullet),
    indent: 0pt,
    body-indent: label-sep,
    spacing: leading,
  )
  set enum(
    numbering: n => marker(numbering("1.", n)),
    indent: 0pt,
    body-indent: label-sep,
    spacing: leading,
  )
  set table(inset: array-inset(body-font-size, body-baseline))
  show raw: set text(font: config.fonts.Mono)
  let body = (
    figure-style,
    equation-style,
    footnote-style,
    heading-style,
    subfigure-style,
  ).fold(
    body,
    (acc, style) => style(config, acc),
  )
  let body = if config.use-latexref {
    show-latexref(config.latexref-prefixes, body)
  } else { body }
  let body = if config.unnumbered-label not in (none, "") {
    show math.equation.where(label: label(
      config.unnumbered-label,
    )): set math.equation(numbering: none)
    body
  } else { body }
  if config.use-fakebold {
    show strong: set text(stroke: 0.015em)
    body
  } else { body }
}

#let document-body(config, body) = page-set(config, _body-style(config, body))

#import "../config.typ": chinese, localized
#import "runtime.typ": thuthesis-runtime
#import "../utils/util.typ": filtered-fields
#import "../utils/text.typ": bp, line-height, tex-pt

#let object-number-at(config, scope, separator, number, location) = context {
  let chapter = counter(heading).at(location).first()
  if scope == "global" or chapter == 0 {
    numbering("1", number)
  } else {
    let chapter-number = numbering(
      if (thuthesis-runtime.appendix-at)(location) { "A" } else { "1" },
      chapter,
    )
    chapter-number + separator + numbering("1", number)
  }
}

#let _object-number(config, scope, separator, number) = context {
  object-number-at(config, scope, separator, number, here())
}

#let _caption-size = bp(11)

#let _caption-baseline(config) = if config.degree == "bachelor" {
  bp(15)
} else if chinese(config) { bp(14.3) } else { bp(12.65) }

#let _caption(config, it) = context {
  align(center, line-height(_caption-size, _caption-baseline(config), {
    if it.numbering != none {
      it.supplement
      text(" ")
      it.counter.display(it.numbering)
      h(1em)
    }
    it.body
  }))
}

#let _figure-style(config, body) = {
  set figure(gap: bp(6))
  show figure: set block(
    above: tex-pt(12),
    below: tex-pt(12),
  )
  show figure: it => context {
    let boundary = (thuthesis-runtime.after-heading-at)(it.location())
    (thuthesis-runtime.clear-after-heading)()
    let styled = {
      let baseline = if chinese(config) { bp(14.3) } else { bp(12.65) }
      let array-stretch = if chinese(config) { 1.42 } else { 1.47 }
      let row-height = baseline * array-stretch
      set text(size: bp(11))
      set par(leading: baseline - bp(11))
      // LaTeX scales the 14.3bp/12.65bp strut by `arraystretch`, retaining
      // its 70% ascent and 30% depth rather than splitting the extra height.
      set table(inset: (
        x: tex-pt(6),
        top: 0.7 * row-height - 0.8 * bp(11),
        bottom: 0.3 * row-height - 0.2 * bp(11),
      ))
      it
    }
    if boundary != none and boundary.kind == "section" {
      pad(top: boundary.figure-correction, styled)
    } else { styled }
  }
  show figure.where(kind: image): set figure(
    supplement: localized(config, [图], [Figure]),
    // TeX's 6bp skip starts at a caption strut with 70% ascent; Typst's
    // caption frame starts at 0.8em. Convert between those two anchors.
    gap: bp(6) + 0.7 * _caption-baseline(config) - 0.8 * _caption-size,
    numbering: n => _object-number(
      config,
      config.figure-numbering,
      config.figure-number-separator,
      n,
    ),
  )
  show figure.where(kind: table): set figure(
    supplement: localized(config, [表], [Table]),
    // Caption's 6bp skip starts at the TeX line strut's bottom. Convert it
    // to Typst's shallower 0.2em caption frame.
    gap: bp(6) + 0.3 * _caption-baseline(config) - 0.2 * _caption-size,
    numbering: n => _object-number(
      config,
      config.table-numbering,
      config.table-number-separator,
      n,
    ),
  )
  show figure.where(kind: "algorithm"): set figure(
    supplement: localized(config, [算法], [Algorithm]),
    numbering: n => _object-number(
      config,
      config.figure-numbering,
      config.figure-number-separator,
      n,
    ),
  )
  show figure.where(kind: table): set figure.caption(position: top)
  show figure.caption: it => _caption(config, it)
  body
}

#let _grid-subfigures(
  format,
  extended,
  outlined,
  parent-number,
  body,
) = {
  if format == none { return body }
  show figure.where(kind: grid): it => {
    let grid-counter = it.counter.get()
    counter(figure.where(kind: image)).update(0)
    show figure.where(kind: image): set figure(outlined: outlined)
    show figure.where(kind: image): set figure(numbering: n => {
      let child = numbering(format, n)
      if extended { [#parent-number(grid-counter.first())#child] } else {
        child
      }
    })
    figure(
      it.body,
      caption: figure.caption(it.caption),
      numbering: none,
      kind: "__tntt:resolved-grid",
      ..filtered-fields(it, (
        "body",
        "caption",
        "numbering",
        "kind",
        "counter",
        "label",
      )),
    )
    counter(figure.where(kind: image)).update(grid-counter)
  }
  body
}

#let _subfigure-style(config, body) = {
  _grid-subfigures(
    config.subfig-numbering,
    config.subfig-numbering-extended,
    config.subfig-outlined,
    n => _object-number(
      config,
      config.figure-numbering,
      config.figure-number-separator,
      n,
    ),
    body,
  )
}

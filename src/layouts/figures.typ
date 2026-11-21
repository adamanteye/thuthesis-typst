#import "../config.typ": chinese, localized
#import "runtime.typ": clear-after-heading, runtime-at
#import "../utils/text.typ": array-inset, bp, line-height, tex-pt
#import "../utils/util.typ": filtered-fields

#let object-number-at(scope, separator, number, location) = context {
  let chapter = counter(heading).at(location).first()
  if scope == "global" or chapter == 0 {
    numbering("1", number)
  } else {
    (
      numbering(
        if runtime-at(location).matter == "appendix" { "A" } else { "1" },
        chapter,
      )
        + separator
        + numbering("1", number)
    )
  }
}

#let object-number(scope, separator, number) = context object-number-at(
  scope,
  separator,
  number,
  here(),
)

#let _caption-size = bp(11)
#let _caption-baseline(config) = if config.degree == "bachelor" {
  bp(15)
} else if chinese(config) { bp(14.3) } else { bp(12.65) }

#let figure-style(config, body) = {
  let num(scope, sep) = n => object-number(scope, sep, n)
  let cap-base = _caption-baseline(config)
  set figure(gap: bp(6))
  show figure: set block(above: tex-pt(12), below: tex-pt(12))
  show figure: it => context {
    let boundary = runtime-at(it.location()).after-heading
    clear-after-heading()
    let styled = {
      let baseline = if chinese(config) { bp(14.3) } else { bp(12.65) }
      let row-height = baseline * if chinese(config) { 1.42 } else { 1.47 }
      set text(size: bp(11))
      set par(leading: baseline - bp(11))
      set table(inset: array-inset(bp(11), row-height))
      it
    }
    if boundary != none and boundary.kind == "section" {
      pad(top: boundary.figure-correction, styled)
    } else { styled }
  }
  show figure.where(kind: image): set figure(
    supplement: localized(config, [图], [Figure]),
    gap: bp(6) + 0.7 * cap-base - 0.8 * _caption-size,
    numbering: num(config.figure-numbering, config.figure-number-separator),
  )
  show figure.where(kind: table): set figure(
    supplement: localized(config, [表], [Table]),
    gap: bp(6) + 0.3 * cap-base - 0.2 * _caption-size,
    numbering: num(config.table-numbering, config.table-number-separator),
  )
  show figure.where(kind: "algorithm"): set figure(
    supplement: localized(config, [算法], [Algorithm]),
    numbering: num(config.figure-numbering, config.figure-number-separator),
  )
  show figure.where(kind: table): set figure.caption(position: top)
  show figure.caption: it => context align(center, line-height(
    _caption-size,
    cap-base,
    {
      if it.numbering != none {
        it.supplement
        text(" ")
        it.counter.display(it.numbering)
        h(1em)
      }
      it.body
    },
  ))
  body
}

#let subfigure-style(config, body) = {
  let format = config.subfig-numbering
  if format == none { return body }
  show figure.where(kind: grid): it => {
    let grid-counter = it.counter.get()
    counter(figure.where(kind: image)).update(0)
    show figure.where(kind: image): set figure(
      outlined: config.subfig-outlined,
      numbering: n => {
        let child = numbering(format, n)
        if config.subfig-numbering-extended {
          let parent = object-number(
            config.figure-numbering,
            config.figure-number-separator,
            grid-counter.first(),
          )
          [#parent#child]
        } else { child }
      },
    )
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

#import "../config.typ": chapter-names
#import "../layouts/figures.typ": object-number-at
#import "../layouts/runtime.typ": runtime-at
#import "common.typ": front-title-outlined, special-chapter
#import "outline-wrapper.typ": (
  dot-leader, fixed-line-block, fixed-line-start, page-at,
)

#let _object-list(config, title, target, scope, separator, supplement: true) = {
  special-chapter(title, outlined: front-title-outlined(config, "list"))
  fixed-line-start()
  show outline.entry: it => context {
    let loc = it.element.location()
    if (
      runtime-at(loc).matter == "appendix"
        and not config.appendix-figure-in-list
    ) { return none }
    let kind = it.element.fields().at("kind", default: none)
    let number = counter(if kind == none { target } else {
      figure.where(kind: kind)
    })
      .at(loc)
      .first()
    let prefix = if it.element.numbering != none {
      if supplement {
        it.element.supplement
        text(" ")
      }
      object-number-at(scope, separator, number, loc)
    }
    let inner = [#it.body()#box(width: 1fr, it.fill)#page-at(loc)]
    fixed-line-block(link(loc, it.indented(prefix, inner, gap: 1em)))
  }
  set outline.entry(fill: dot-leader)
  outline(title: none, target: target)
}

#let list-of-figures(config) = _object-list(
  config,
  chapter-names(config).figures,
  figure.where(kind: image),
  config.figure-numbering,
  config.figure-number-separator,
)

#let list-of-tables(config) = _object-list(
  config,
  chapter-names(config).tables,
  figure.where(kind: table),
  config.table-numbering,
  config.table-number-separator,
)

#let list-of-figures-and-tables(config) = _object-list(
  config,
  chapter-names(config).figures-tables,
  figure.where(kind: image).or(figure.where(kind: table)),
  config.figure-numbering,
  config.figure-number-separator,
)

#let list-of-equations(config) = _object-list(
  config,
  chapter-names(config).equations,
  math.equation.where(block: true),
  config.equation-numbering,
  config.equation-number-separator,
  supplement: false,
)

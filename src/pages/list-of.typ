#import "../config.typ": chapter-names
#import "../layouts/runtime.typ": thuthesis-runtime
#import "common.typ": _front-title-outlined, _inside, _special-chapter
#import "outline-wrapper.typ": _dot-leader, _fixed-line-block, _fixed-line-start, _page-at

#let _source-numbered-outline-entry(
  env,
  it,
  target,
  scope,
  separator,
  supplement: true,
) = context {
  let location = it.element.location()
  if (
    (thuthesis-runtime.appendix-at)(location)
      and not env.config.appendix-figure-in-list
  ) {
    none
  } else {
    let kind = it.element.fields().at("kind", default: none)
    let number-target = if kind == none {
      target
    } else {
      figure.where(kind: kind)
    }
    let number = counter(number-target).at(location).first()
    let prefix = if it.element.numbering == none {
      none
    } else {
      {
        if supplement {
          it.element.supplement
          text(" ")
        }
        (env.layout.object-number-at)(scope, separator, number, location)
      }
    }
    let inner = [#it.body()#box(width: 1fr, it.fill)#_page-at(location)]
    _fixed-line-block(
      link(location, it.indented(prefix, inner, gap: 1em)),
    )
  }
}

#let _object-list(
  env,
  title,
  target,
  scope,
  separator,
  outlined: auto,
  header: auto,
  supplement: true,
) = {
  let config = env.config
  _special-chapter(
    env,
    title,
    outlined: if outlined == auto {
      _front-title-outlined(config, "list")
    } else { outlined },
    header: header,
  )
  _fixed-line-start()
  show outline.entry: it => _source-numbered-outline-entry(
    env,
    it,
    target,
    scope,
    separator,
    supplement: supplement,
  )
  set outline.entry(fill: _dot-leader)
  outline(title: none, target: target)
}

#let _list-of-figures(env) = _inside(env, config => _object-list(
  env,
  chapter-names(config).figures,
  figure.where(kind: image),
  config.figure-numbering,
  config.figure-number-separator,
))

#let _list-of-tables(env) = _inside(env, config => _object-list(
  env,
  chapter-names(config).tables,
  figure.where(kind: table),
  config.table-numbering,
  config.table-number-separator,
))

#let _list-of-figures-and-tables(env) = _inside(env, config => _object-list(
  env,
  chapter-names(config).figures-tables,
  figure.where(kind: image).or(figure.where(kind: table)),
  config.figure-numbering,
  config.figure-number-separator,
))

#let _list-of-algorithms(env) = _inside(env, config => _object-list(
  env,
  chapter-names(config).algorithms,
  figure.where(kind: "algorithm"),
  config.figure-numbering,
  config.figure-number-separator,
))

#let _list-of-equations(env) = _inside(env, config => _object-list(
  env,
  chapter-names(config).equations,
  math.equation.where(block: true),
  config.equation-numbering,
  config.equation-number-separator,
  supplement: false,
))

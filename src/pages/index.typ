#import "abstract.typ": _abstract-en, _abstract-zh
#import "achievement.typ": _achievements, _resume
#import "acknowledge.typ": _acknowledgements
#import "bibliography.typ": _bibliography-thu
#import "committee.typ": _committee
#import "common.typ": _inside
#import "copyright.typ": _authorization-component
#import "declaration.typ": _statement
#import "fonts-display.typ": _fonts-display
#import "list-of.typ": (
  _list-of-algorithms,
  _list-of-equations,
  _list-of-figures,
  _list-of-figures-and-tables,
  _list-of-tables,
)
#import "notation.typ": _denotation
#import "outline-wrapper.typ": _table-of-contents
#import "review-of.typ": _comments, _record, _resolution
#import "scanned.typ": _scanned-pages
#import "translation.typ": _survey, _translation, _translation-index

#let _algorithm-figure(caption: none, body) = figure(
  kind: "algorithm",
  caption: caption,
  body,
)

#let page-instance(config, layout) = {
  let env = (config: config, layout: layout)
  (
    abstract-zh: (..args) => _abstract-zh(env, ..args),
    abstract-en: (..args) => _abstract-en(env, ..args),
    table-of-contents: (..args) => _table-of-contents(env, ..args),
    list-of-figures: (..args) => _list-of-figures(env, ..args),
    list-of-tables: (..args) => _list-of-tables(env, ..args),
    list-of-figures-and-tables: (..args) => _list-of-figures-and-tables(
      env,
      ..args,
    ),
    list-of-algorithms: (..args) => _list-of-algorithms(env, ..args),
    list-of-equations: (..args) => _list-of-equations(env, ..args),
    committee: (..args) => _committee(env, ..args),
    authorization: (..args) => _authorization-component(env, ..args),
    scanned-pages: (..args) => _scanned-pages(env, ..args),
    denotation: (..args) => _denotation(env, ..args),
    acknowledgements: (..args) => _acknowledgements(env, ..args),
    resume: (..args) => _resume(env, ..args),
    achievements: (..args) => _achievements(env, ..args),
    comments: (..args) => _comments(env, ..args),
    resolution: (..args) => _resolution(env, ..args),
    statement: (..args) => _statement(env, ..args),
    record: (..args) => _record(env, ..args),
    bibliography-thu: (..args) => if config.bibliography == none {
      _bibliography-thu(env, ..args)
    } else {
      _bibliography-thu(env, none, ..args)
    },
    fonts-display: (..args) => _fonts-display(env, ..args),
    algorithm-figure: (..args) => _inside(
      env,
      _ => _algorithm-figure(..args),
    ),
    survey: body => _inside(env, _ => _survey(body)),
    translation: body => _inside(env, _ => _translation(body)),
    translation-index: (..args) => _translation-index(env, ..args),
  )
}

#import "../config.typ": chapter-names, is-graduate
#import "../layouts/pagebreak.typ": clear-page
#import "common.typ": _inside, _once, _special-chapter
#import "scanned.typ": _scanned-pages

#let _comments(env, title: auto, header: auto, body) = _inside(env, config => {
  if is-graduate(config) and not config.anonymous {
    _special-chapter(
      env,
      if title == auto { chapter-names(config).comments } else { title },
      header: header,
    )
    body
    clear-page(weak: true)
  }
})

#let _resolution(env, title: auto, header: auto, body) = _inside(
  env,
  config => {
    if is-graduate(config) and not config.anonymous {
      _special-chapter(
        env,
        if title == auto { chapter-names(config).resolution } else { title },
        header: header,
      )
      body
      clear-page(weak: true)
    }
  },
)

#let _record(env, file, pages: (1,)) = _inside(env, config => {
  if config.degree == "bachelor" and not config.anonymous {
    _once("record", _scanned-pages(env, file, pages: pages))
  }
})

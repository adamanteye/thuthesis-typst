#import "../config.typ": is-graduate
#import "../layouts/pagebreak.typ": clear-double-page, clear-page
#import "common.typ": _inside, _once
#import "scanned.typ": _scanned-pages

#let _committee(
  env,
  title: [学位论文指导小组、公开评阅人和答辩委员会名单],
  file: none,
  body,
) = _inside(env, config => {
  if is-graduate(config) and not config.anonymous {
    _once("committee", {
      clear-double-page(config, weak: true)
      if file != none {
        _scanned-pages(env, file)
      } else {
        set page(header: none, footer: none, numbering: none)
        (env.layout.heading-style)(variant: "committee", {
          heading(level: 1, numbering: none, outlined: false, title)
          if body != none { body }
        })
        clear-page()
      }
    })
  }
})

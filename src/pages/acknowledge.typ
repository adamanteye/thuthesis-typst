#import "../config.typ": chapter-names
#import "common.typ": _inside, _special-chapter

#let _acknowledgements(env, title: auto, header: auto, body) = _inside(
  env,
  config => {
    if config.anonymous { return }
    _special-chapter(
      env,
      if title == auto { chapter-names(config).acknowledgements } else {
        title
      },
      header: header,
      kind: "acknowledgements",
    )
    body
  },
)

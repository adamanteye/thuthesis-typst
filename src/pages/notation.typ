#import "../config.typ": chapter-names
#import "common.typ": _front-title-outlined, _inside, _special-chapter
#import "../utils/text.typ": bp

#let _denotation(
  env,
  entries,
  label-width: 2.5cm,
  title: auto,
  header: auto,
) = _inside(
  env,
  config => {
    assert(
      type(entries) == array,
      message: "thuthesis: denotation entries must be an array",
    )
    assert(
      type(label-width) == length and label-width > 0pt,
      message: "thuthesis: denotation label-width must be a positive length",
    )
    let names = chapter-names(config)
    _special-chapter(
      env,
      if title == auto { names.denotation } else { title },
      outlined: _front-title-outlined(config, "list"),
      header: header,
    )
    for entry in entries {
      assert(
        type(entry) == array and entry.len() == 2,
        message: "thuthesis: each denotation entry must be `(symbol, description)`",
      )
    }
    // TeX's global `\sloppy` and xeCJK punctuation handling let dense rows
    // trade inter-word space and hang closing punctuation before breaking.
    set par(linebreaks: "optimized")
    let cell = body => pad(bottom: bp(8), body)
    grid(
      columns: (label-width, 1fr),
      column-gutter: 0.5cm,
      row-gutter: 0pt,
      ..entries
        .map(entry => (
          cell(entry.at(0)),
          cell(entry.at(1)),
        ))
        .flatten(),
    )
  },
)

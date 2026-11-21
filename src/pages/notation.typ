#import "../config.typ": chapter-names
#import "common.typ": front-title-outlined, special-chapter
#import "../utils/text.typ": bp

#let denotation(
  config,
  entries,
  label-width: 2.5cm,
  title: auto,
  header: auto,
) = {
  special-chapter(
    if title == auto { chapter-names(config).denotation } else { title },
    outlined: front-title-outlined(config, "list"),
    header: header,
  )
  set par(linebreaks: "optimized")
  grid(
    columns: (label-width, 1fr),
    column-gutter: 0.5cm,
    row-gutter: 0pt,
    ..entries
      .map(((sym, desc)) => (pad(bottom: bp(8), sym), pad(bottom: bp(8), desc)))
      .flatten(),
  )
}

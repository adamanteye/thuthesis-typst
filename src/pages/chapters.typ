#import "../config.typ": chapter-names, is-graduate
#import "../layouts/headings.typ": heading-style
#import "../layouts/page.typ": clear-double-page
#import "common.typ": special-chapter
#import "scanned.typ": scanned-pages

#let committee(
  config,
  title: [学位论文指导小组、公开评阅人和答辩委员会名单],
  file: none,
  body,
) = if (
  is-graduate(config) and not config.anonymous
) {
  clear-double-page(config)
  if file != none {
    scanned-pages(config, file)
  } else {
    set page(header: none, footer: none, numbering: none)
    heading-style(config, variant: "committee", {
      heading(level: 1, numbering: none, outlined: false, title)
      if body != none { body }
    })
    pagebreak()
  }
}

#let acknowledgements(
  config,
  title: auto,
  header: auto,
  body,
) = if not config.anonymous {
  special-chapter(
    if title == auto { chapter-names(config).acknowledgements } else { title },
    header: header,
    kind: "acknowledgements",
  )
  body
}

#let _graduate-review(config, key, title: auto, header: auto, body) = if (
  is-graduate(config) and not config.anonymous
) {
  special-chapter(
    if title == auto { chapter-names(config).at(key) } else { title },
    header: header,
  )
  body
  pagebreak(weak: true)
}

#let comments(config, ..args) = _graduate-review(config, "comments", ..args)
#let resolution(config, ..args) = _graduate-review(config, "resolution", ..args)

#let record-sheet(config, file, pages: (1,)) = if (
  config.degree == "bachelor" and not config.anonymous
) {
  scanned-pages(config, file, pages: pages)
}

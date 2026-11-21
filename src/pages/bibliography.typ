#import "@preview/gb7714-bilingual:0.2.3": gb7714-bibliography, init-gb7714
#import "../config.typ": chapter-names, chinese
#import "../layouts/runtime.typ": runtime-at
#import "common.typ": source-path
#import "../utils/text.typ": bp, line-height

/// Configure the optional GB/T 7714 bilingual bibliography engine.
#let thuthesis-bib(
  sources,
  style: "2015",
  citation-style: "numeric",
  show-url: true,
  show-doi: true,
  show-accessed: true,
) = (
  sources: if type(sources) == array { sources.map(str).join("\n") } else {
    str(sources)
  },
  style: style,
  citation-style: citation-style,
  show-url: show-url,
  show-doi: show-doi,
  show-accessed: show-accessed,
)

#let bibliography-document(bib, body) = if bib == none {
  body
} else {
  init-gb7714(
    bib.sources,
    style: bib.citation-style,
    version: bib.style,
    show-url: bib.show-url,
    show-doi: bib.show-doi,
    show-accessed: bib.show-accessed,
    body,
  )
}

#let bibliography-thu(
  config,
  ..sources,
  style: auto,
  title: auto,
  full: false,
  target: auto,
  group: auto,
) = {
  let sources = sources.pos().at(0, default: none)
  let bib-title = if title == auto { chapter-names(config).bibliography } else {
    title
  }
  let en-bachelor = config.degree == "bachelor" and not chinese(config)
  let baseline = if en-bachelor { bp(17) } else { bp(16) }
  let item-gap = if en-bachelor { bp(6) } else { bp(3) }
  let entry-style(body) = {
    set par(linebreaks: "optimized")
    line-height(
      bp(10.5),
      baseline,
      body,
      paragraph-spacing: baseline - bp(10.5) + item-gap,
    )
  }
  if config.bibliography != none {
    let numeric = config.bibliography.citation-style == "numeric"
    let hanging = if en-bachelor { 0.5in } else { bp(21) }
    return context {
      heading(
        level: if runtime-at(here()).matter == "appendix" { 2 } else { 1 },
        numbering: none,
        bib-title,
      )
      entry-style(gb7714-bibliography(
        title: none,
        full: full,
        full-control: entries => {
          set par(first-line-indent: 0pt, hanging-indent: if numeric {
            1cm
          } else { hanging })
          for entry in entries {
            if numeric { box(width: 1cm, [[#entry.order]]) }
            entry.labeled-rendered
            parbreak()
          }
        },
      ))
    }
  }
  let selected = if style == auto { config.bibliography-style } else { style }
  let csl = if selected == "author-year" { "gb-7714-2015-author-date" } else {
    "gb-7714-2015-numeric"
  }
  show bibliography: it => context {
    set heading(level: if runtime-at(it.location()).matter == "appendix" {
      2
    } else { 1 })
    entry-style(it)
  }
  bibliography(
    if type(sources) == array { sources.map(source-path) } else {
      source-path(sources)
    },
    title: bib-title,
    style: csl,
    full: full,
    target: target,
    group: group,
  )
}

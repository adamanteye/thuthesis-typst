#import "../config.typ": chapter-names, chinese
#import "../layouts/runtime.typ": thuthesis-runtime
#import "common.typ": _inside, _source-path
#import "../utils/text.typ": bp, line-height

/// Configures the optional GB/T 7714 bilingual bibliography engine.
///
/// The built-in `bibliography` remains available for users who prefer Typst's
/// CSL renderer. This opt-in engine is initialized around `meta`,
/// which lets it inspect each BibTeX entry's `language` or `langid` field.
#import "@preview/gb7714-bilingual:0.2.3": gb7714-bibliography, init-gb7714

/// Create the value passed to `define-config(bibliography: ...)`.
///
/// `sources` is BibTeX text read at the template call site. `style` chooses
/// the GB/T edition. `2015` is the default; `2025` is available only when a
/// document explicitly opts into the newer standard.
#let thuthesis-bib(
  sources,
  style: "2015",
  citation-style: "numeric",
  show-url: true,
  show-doi: true,
  show-accessed: true,
) = (
  engine: "thuthesis-bib",
  sources: sources,
  style: style,
  citation-style: citation-style,
  show-url: show-url,
  show-doi: show-doi,
  show-accessed: show-accessed,
)

#let _source-text(source) = {
  assert(
    type(source) in (str, bytes),
    message: "thuthesis-bib: every bibliography source must be text or bytes",
  )
  str(source)
}

#let _sources-text(sources) = if type(sources) == array {
  assert(
    sources.len() > 0,
    message: "thuthesis-bib: `sources` must not be empty",
  )
  sources.map(_source-text).join("\n")
} else {
  _source-text(sources)
}

/// Validate and normalize the optional `bibliography` configuration value.
#let normalize(value) = {
  if value == none { return none }
  assert(
    type(value) == dictionary
      and value.at("engine", default: none) == "thuthesis-bib",
    message: "thuthesis: `bibliography` must be `thuthesis-bib(...)` or none",
  )
  for key in value.keys() {
    assert(
      key
        in (
          "engine",
          "sources",
          "style",
          "citation-style",
          "show-url",
          "show-doi",
          "show-accessed",
        ),
      message: "thuthesis-bib: unknown option `" + key + "`",
    )
  }
  assert(
    "sources" in value,
    message: "thuthesis-bib: `sources` is required",
  )
  let style = value.at("style", default: "2015")
  let citation-style = value.at("citation-style", default: "numeric")
  assert(
    style in ("2015", "2025"),
    message: "thuthesis-bib: `style` must be `2015` or `2025`",
  )
  assert(
    citation-style in ("numeric", "author-date"),
    message: "thuthesis-bib: `citation-style` must be `numeric` or `author-date`",
  )
  for key in ("show-url", "show-doi", "show-accessed") {
    assert(
      type(value.at(key, default: true)) == bool,
      message: "thuthesis-bib: `" + key + "` must be boolean",
    )
  }
  (
    sources: _sources-text(value.sources),
    style: style,
    citation-style: citation-style,
    show-url: value.at("show-url", default: true),
    show-doi: value.at("show-doi", default: true),
    show-accessed: value.at("show-accessed", default: true),
  )
}

/// Apply the selected engine to the whole thesis document.
#let document(bibliography, body) = if bibliography == none {
  body
} else {
  init-gb7714(
    bibliography.sources,
    style: bibliography.citation-style,
    version: bibliography.style,
    show-url: bibliography.show-url,
    show-doi: bibliography.show-doi,
    show-accessed: bibliography.show-accessed,
    body,
  )
}

/// Render the bibliography entries collected by the configured engine.
#let render(bibliography, full: false, hanging-indent: 2em) = {
  assert(
    bibliography != none,
    message: "thuthesis: `thuthesis-bib` is not configured",
  )
  let numeric = bibliography.citation-style == "numeric"
  // ThuThesis reserves a left-aligned 1 cm label column for numeric lists.
  // Author-date entries instead hang from their unnumbered first line.
  gb7714-bibliography(title: none, full: full, full-control: entries => {
    set par(first-line-indent: 0pt, hanging-indent: if numeric { 1cm } else { hanging-indent })
    for entry in entries {
      if numeric { box(width: 1cm, [[#entry.order]]) }
      entry.labeled-rendered
      parbreak()
    }
  })
}

#let _bibliography-thu(
  env,
  sources,
  style: auto,
  title: auto,
  full: false,
  target: auto,
  group: auto,
) = _inside(env, config => {
  let bibliography-title = if title == auto {
    chapter-names(config).bibliography
  } else { title }
  let english-bachelor = config.degree == "bachelor" and not chinese(config)
  let baseline = if english-bachelor { bp(17) } else { bp(16) }
  let item-gap = if english-bachelor { bp(6) } else { bp(3) }
  let entry-style(body) = {
    set par(linebreaks: "optimized")
    line-height(bp(10.5), baseline, body, paragraph-spacing: baseline - bp(10.5) + item-gap)
  }
  if config.bibliography != none {
    assert(
      sources == none,
      message: "thuthesis: sources are already configured in `thuthesis-bib`, call `bibliography-thu()` without sources",
    )
    assert(
      style == auto and target == auto and group == auto,
      message: "thuthesis: set bilingual bibliography options in `thuthesis-bib(...)`",
    )
    return context {
      let appendix = (thuthesis-runtime.appendix-at)(here())
      heading(
        level: if appendix { 2 } else { 1 },
        numbering: none,
        bibliography-title,
      )
      entry-style(render(
        config.bibliography,
        full: full,
        hanging-indent: if english-bachelor { 0.5in } else { bp(21) },
      ))
    }
  }
  assert(
    sources != none,
    message: "thuthesis: `bibliography-thu` requires sources unless `thuthesis-bib(...)` is configured",
  )
  let selected = if style == auto { config.bibliography-style } else { style }
  assert(
    selected in ("numeric", "author-year", "bachelor"),
    message: "thuthesis: invalid bibliography style",
  )
  let csl = if selected == "author-year" {
    "gb-7714-2015-author-date"
  } else {
    "gb-7714-2015-numeric"
  }
  show bibliography: it => context {
    // LaTeX renders the main bibliography as a chapter, but an appendix's
    // independently numbered bibliography as an unnumbered section inside
    // that appendix chapter.
    let appendix = (thuthesis-runtime.appendix-at)(it.location())
    set heading(level: if appendix { 2 } else { 1 })
    entry-style(it)
  }
  bibliography(
    if type(sources) == array { sources.map(_source-path) } else { _source-path(sources) },
    title: bibliography-title,
    style: csl,
    full: full,
    target: target,
    group: group,
  )
})

//! TnTT's LaTeX-aligned thesis core.

#import "config.typ": normalize
#import "layouts/doc.typ": document-body, document-meta, layout-instance
#import "pages/bibliography.typ": document as bibliography-document, normalize as normalize-bibliography, thuthesis-bib
#import "pages/cover.typ": first-title-page, second-title-page
#import "pages/index.typ": page-instance

#let thesis-config(options) = {
  let config = normalize(options)
  let bibliography = normalize-bibliography(config.bibliography)
  config + (
    bibliography: bibliography,
    bibliography-style: if bibliography == none { config.bibliography-style } else { bibliography.citation-style },
  )
}

// Page-level layouts keep the covers outside the body show rule.
#let thesis-pages(config) = {
  let layout = layout-instance(config)
  let pages = page-instance(config, layout)
  (
    meta: body => bibliography-document(config.bibliography, document-meta(config, body)),
    cover: () => first-title-page(config),
    cover-en: () => second-title-page(config),
    doc: document-body.with(config),
    front-matter: layout.frontmatter,
    main-matter: layout.mainmatter,
    appendix: layout.appendix,
    back-matter: layout.backmatter,
    spine: layout.spine,
    fonts-display: pages.fonts-display,
    committee: pages.committee,
    copyright: pages.authorization,
    abstract: pages.abstract-zh,
    abstract-en: pages.abstract-en,
    outline-wrapper: pages.table-of-contents,
    figure-list: pages.list-of-figures,
    table-list: pages.list-of-tables,
    figure-table-list: pages.list-of-figures-and-tables,
    equation-list: pages.list-of-equations,
    notation: pages.denotation,
    bibliography-thu: pages.bibliography-thu,
    acknowledge: pages.acknowledgements,
    declaration: pages.statement,
    achievement: pages.resume,
    achievements: pages.achievements,
    record-sheet: pages.record,
    comments: pages.comments,
    resolution: pages.resolution,
  )
}

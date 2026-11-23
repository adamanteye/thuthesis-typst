//! The main configuration file for the TNTT template.

#import "config.typ": build-config
#import "layouts/doc.typ": document-body, document-meta
#import "layouts/matter.typ": matter
#import "pages/abstract.typ": abstract-en, abstract-zh
#import "pages/achievement.typ": achievements, resume
#import "pages/bibliography.typ": (
  bibliography-document, bibliography-thu, thuthesis-bib,
)
#import "pages/chapters.typ": (
  acknowledgements, comments, committee, record-sheet, resolution,
)
#import "pages/copyright.typ": authorization
#import "pages/cover.typ": first-title-page, second-title-page
#import "pages/declaration.typ": statement
#import "pages/fonts-display.typ": fonts-display
#import "pages/list-of.typ": (
  list-of-equations, list-of-figures, list-of-figures-and-tables,
  list-of-tables,
)
#import "pages/notation.typ": denotation
#import "pages/outline-wrapper.typ": table-of-contents
#import "pages/spine.typ": spine-page

/// Define the configuration for the document.
///
/// - degree (str): The degree (`"bachelor"`, `"master"`, `"doctor"`, or `"postdoc"`).
/// - degree-type (str): The degree type (`"academic"` or `"professional"`).
/// - anonymous (str, bool): Whether to use anonymous mode.
/// - twoside (str, bool): Whether to use two-sided printing.
/// - bibliography (dictionary, none): Optional bilingual bibliography configured with `thuthesis-bib(...)`.
/// - fonts (str, dictionary): Font preset name or custom font-family dictionary.
/// - info (dictionary): Document metadata and cover information.
/// -> dictionary
#let define-config(
  degree: "bachelor",
  degree-type: "academic",
  anonymous: false,
  twoside: false,
  bibliography: none,
  fonts: (:),
  info: (:),
  ..options,
) = {
  degree = sys.inputs.at("degree", default: degree)
  degree-type = sys.inputs.at("degree-type", default: degree-type)
  anonymous = sys.inputs.at("anonymous", default: anonymous) in (true, "true")
  twoside = sys.inputs.at("twoside", default: twoside)

  let config = build-config(
    degree,
    degree-type,
    anonymous,
    twoside,
    fonts,
    info,
    bibliography,
    options.named(),
  )

  (
    info: config.info,
    fonts: config.fonts,
    degree-type: config.degree-type,
    degree: config.degree,
    twoside: twoside,
    anonymous: config.anonymous,
    meta: body => bibliography-document(config.bibliography, document-meta(
      config,
      body,
    )),
    cover: () => first-title-page(config),
    cover-en: () => second-title-page(config),
    doc: document-body.with(config),
    front-matter: body => matter(config, "front", body),
    main-matter: body => matter(config, "main", body),
    appendix: body => matter(config, "appendix", body),
    back-matter: body => matter(config, "back", body),
    spine: () => spine-page(config),
    fonts-display: fonts-display.with(config),
    committee: committee.with(config),
    copyright: authorization.with(config),
    abstract: abstract-zh.with(config),
    abstract-en: abstract-en.with(config),
    outline-wrapper: table-of-contents.with(config),
    figure-list: list-of-figures.with(config),
    table-list: list-of-tables.with(config),
    figure-table-list: list-of-figures-and-tables.with(config),
    equation-list: list-of-equations.with(config),
    notation: denotation.with(config),
    bibliography-thu: bibliography-thu.with(config),
    acknowledge: acknowledgements.with(config),
    declaration: statement.with(config),
    achievement: resume.with(config),
    achievements: achievements.with(config),
    record-sheet: record-sheet.with(config),
    comments: comments.with(config),
    resolution: resolution.with(config),
  )
}

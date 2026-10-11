#import "figures.typ": object-number-at
#import "headings.typ": heading-style
#import "main-matter.typ": _body-style
#import "matter.typ": _matter
#import "page.typ": _page-numbering, _page-set, page-footer, page-header
#import "runtime.typ": thuthesis-runtime
#import "../pages/spine.typ": spine-page

#let document-meta(config, body) = {
  set document(
    title: config.metadata.title,
    author: if config.anonymous { () } else { (config.metadata.author,) },
    description: config.metadata.subject,
  )
  (thuthesis-runtime.start)()
  // A selected profile is authoritative. Do not silently embed an unrelated
  // system fallback when one of its fonts lacks a glyph.
  set text(fallback: false)
  // The English abstract breaks closer to XeLaTeX with a lower hyphenation
  // cost and with line-final hyphens kept inside the text block.
  set text(costs: (hyphenation: 25%), overhang: false)
  body
  (thuthesis-runtime.finish)()
}

#let document-body(config, body) = _page-set(config, _body-style(config, body))

#let layout-instance(config) = (
  frontmatter: body => _matter(config, "front", body),
  mainmatter: body => _matter(config, "main", body),
  appendix: body => _matter(config, "appendix", body),
  backmatter: body => _matter(config, "back", body),
  spine: () => {
    (thuthesis-runtime.require-active)()
    spine-page(config)
  },
  heading-style: (body, variant: "body") => heading-style(
    config,
    body,
    variant: variant,
  ),
  page-header: () => page-header(config),
  scanned-page-header: () => page-header(config, compensate-ascent: false),
  page-footer: (numbering: _page-numbering) => page-footer(
    config,
    numbering: numbering,
  ),
  object-number-at: (scope, separator, number, location) => object-number-at(
    config,
    scope,
    separator,
    number,
    location,
  ),
)

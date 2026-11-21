#import "../config.typ": chinese
#import "page.typ": clear-double-page
#import "runtime.typ": transition

#let _appendix-citation-style(config, body) = if (
  config.bibliography-style == "author-year"
) {
  body
} else {
  let csl = read("appendix-citation.csl")
  show cite.where(style: auto): it => context {
    let chapter = counter(heading).at(here()).first()
    cite(
      it.key,
      supplement: it.supplement,
      form: it.form,
      style: bytes(csl.replace("THUTHESIS_APPENDIX", numbering("A", chapter))),
    )
  }
  show regex("^\\[[0-9]+\\]$"): label => context {
    let chapter = counter(heading).at(here()).first()
    text(label.text.replace("[", "[" + numbering("A", chapter) + "."))
  }
  body
}

#let matter(config, kind, body) = {
  if kind in ("front", "main") {
    clear-double-page(config)
    counter(page).update(1)
  } else if kind == "back" {
    pagebreak(weak: true)
  }
  transition(kind)
  if kind == "appendix" {
    counter(heading).update(0)
    set heading(numbering: if chinese(config) { "附录 A.1.1.1" } else {
      "APPENDIX A.1.1.1"
    })
    _appendix-citation-style(config, body)
  } else {
    body
  }
}

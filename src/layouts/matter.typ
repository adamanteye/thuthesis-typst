#import "../config.typ": chinese
#import "pagebreak.typ": clear-double-page, clear-page
#import "runtime.typ": thuthesis-runtime

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
      style: bytes(csl.replace(
        "THUTHESIS_APPENDIX",
        numbering("A", chapter),
      )),
    )
  }
  show regex("^\\[[0-9]+\\]$"): label => context {
    let chapter = counter(heading).at(here()).first()
    text(label.text.replace("[", "[" + numbering("A", chapter) + "."))
  }
  body
}

#let _matter(config, kind, body) = {
  (thuthesis-runtime.require-active)()
  if kind in ("front", "main") {
    clear-double-page(config, weak: true)
    counter(page).update(1)
  } else if kind == "back" {
    clear-page(weak: true)
  }
  (thuthesis-runtime.transition)(kind, appendix: kind == "appendix")
  if kind == "appendix" { counter(heading).update(0) }
  if kind == "appendix" {
    // The semantic heading numbering is also used for PDF bookmarks. The
    // chapter renderer supplies the same label visually, while this scoped
    // pattern makes the bookmark read “附录 A …” instead of “1 …”.
    set heading(numbering: if chinese(config) { "附录 A.1.1.1" } else {
      "APPENDIX A.1.1.1"
    })
    _appendix-citation-style(config, body)
  } else { body }
}

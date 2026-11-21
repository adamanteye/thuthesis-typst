//! Utility helpers for TNTT compatibility options.

#let filtered-fields(el, keys) = el.fields().pairs().filter(((k, _)) => k not in keys).to-dict()

#let show-latexref(prefixes, doc) = {
  show ref: it => {
    if it.element != none { return it }
    let target = str(it.target)
    let stripped = for p in prefixes { if target.starts-with(p) { target.slice(p.len()) + break } }
    if stripped == none { return it }
    ref(label(stripped), ..filtered-fields(it, ("target", "element", "citation")))
  }
  doc
}

//! Utility functions for TNTT templates.

/// Filter out specified fields from an element's fields and return a new dictionary with the remaining fields.
///
/// - el (any): Element to filter fields from
/// - keys (array): The keys of the fields to filter out
/// -> dictionary
#let filtered-fields(el, keys) = el.fields().pairs().filter(((k, _)) => k not in keys).to-dict()

/// Apply compatibility rewrite for refs.
///
/// * Author: An-314
/// * Modified by: chillcicada
///
/// - prefixes (array): An array of prefixes to strip from the ref targets, such as "fig:", "tbl:", etc.
/// - doc (content): The document content to be displayed with the rewritten refs.
/// -> content
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

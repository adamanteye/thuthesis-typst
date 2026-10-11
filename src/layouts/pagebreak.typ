#let clear-page(weak: false) = pagebreak(weak: weak)

#let clear-double-page(config, weak: false) = if config.output == "print" {
  // Keep each style rule in the same lexical scope as the pagebreak: Typst
  // then applies it to the inserted leaf rather than to later content.
  if config.blank-page-style == "no-content" {
    set page(header: none, footer: none, numbering: none)
    pagebreak(to: "odd", weak: weak)
  } else if config.blank-page-style == "no-header" {
    set page(header: none)
    pagebreak(to: "odd", weak: weak)
  } else if config.blank-page-style == "no-numbering" {
    set page(footer: none, numbering: none)
    pagebreak(to: "odd", weak: weak)
  } else {
    set page(header: none, footer: none, numbering: none)
    [#metadata(none) <__tntt:pagebreak-blank-only>]
    pagebreak(to: "odd", weak: weak)
  }
} else {
  pagebreak(weak: weak)
}

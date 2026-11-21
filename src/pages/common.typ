#import "../config.typ": is-graduate
#import "../layouts/runtime.typ": special-heading
#import "../utils/text.typ": tex-pt

// String filenames passed to page helpers resolve from src/.
#let source-path(value) = if type(value) == str and not value.starts-with("/") {
  path("../" + value)
} else { value }

#let front-title-outlined(config, kind) = if kind in ("contents", "abstract") {
  is-graduate(config)
} else {
  (
    is-graduate(config)
      or (config.degree == "bachelor" and config.language == "english")
  )
}

#let special-chapter(
  title,
  outlined: true,
  header: auto,
  kind: "special",
) = special-heading(
  kind,
  header,
  heading(level: 1, numbering: none, outlined: outlined, title),
)

// `\thu@underline` wraps TeX's primitive `\underline` (XITS Math 0.198em/0.066em) in 1pt/3pt skips.
#let signature-line(size, width, trailing: true) = {
  let thickness = 0.066 * size
  h(tex-pt(1))
  box(width: width, height: 0pt, place(
    top + left,
    dy: 0.198 * size + thickness / 2,
    line(length: 100%, stroke: thickness),
  ))
  if trailing { h(tex-pt(3)) }
}

#let cover-page(margin, body) = {
  set page(
    paper: "a4",
    margin: margin,
    header: none,
    footer: none,
    numbering: none,
  )
  body
  pagebreak()
}

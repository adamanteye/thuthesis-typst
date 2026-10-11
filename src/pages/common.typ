#import "../config.typ": is-graduate
#import "../layouts/runtime.typ": thuthesis-runtime
#import "../utils/text.typ": tex-pt

// String filenames passed to LaTeX-aligned page helpers resolve from src/.
#let _source-path(value) = if type(value) == str and not value.starts-with("/") {
  path("../" + value)
} else { value }

#let _inside(env, render) = {
  (thuthesis-runtime.require-active)()
  render(env.config)
}

#let _once(name, body) = (thuthesis-runtime.once)(name, body)

#let _front-title-outlined(config, kind) = if (
  kind in ("contents", "abstract")
) {
  is-graduate(config)
} else {
  (
    is-graduate(config)
      or (config.degree == "bachelor" and config.language == "english")
  )
}

#let _special-chapter(
  env,
  title,
  body: none,
  outlined: true,
  outline-title: auto,
  header: auto,
  kind: "special",
) = _inside(env, config => {
  let outline-title = if outline-title == auto { title } else {
    outline-title
  }
  // Keep `header: auto` as a policy. Each projection is rendered later from
  // logical title content through the title renderer.
  (thuthesis-runtime.begin-special-heading)(kind, outline-title, header)
  heading(level: 1, numbering: none, outlined: outlined, title)
  (thuthesis-runtime.end-special-heading)()
  if body != none { body }
})

// `\thu@underline` wraps TeX's primitive `\underline` in 1pt/3pt skips.
// XITS Math defines its underline gap and thickness as 0.198em and 0.066em.
#let _signature-line(size, width, trailing: true) = {
  let thickness = 0.066 * size
  h(tex-pt(1))
  box(width: width, height: 0pt, {
    place(
      top + left,
      dy: 0.198 * size + thickness / 2,
      line(length: 100%, stroke: thickness),
    )
  })
  // TeX discards the macro's final 3pt glue at a paragraph boundary.
  if trailing { h(tex-pt(3)) }
}

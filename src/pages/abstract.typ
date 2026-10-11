#import "../config.typ": chapter-names, sans-fonts, serif-fonts
#import "../layouts/runtime.typ": thuthesis-runtime
#import "common.typ": _front-title-outlined, _inside
#import "../utils/text.typ": bp

// Render keyword rows from explicit inline tokens. Whitespace in Typst
// markup is document content, so formatting this function across source
// lines must not silently change the distance after the label.
#let _keyword-line(config, language, keywords) = {
  let postdoc = config.degree == "postdoc"
  let indent = if postdoc { h(2em) } else { [] }
  if language == "chinese" {
    let label = if postdoc {
      strong[关键词：]
    } else {
      text(font: sans-fonts(config), [关键词：])
    }
    // `thuthesis.dtx` ends the label with `%`: no glue precedes the first
    // Chinese keyword.
    [#indent#label#keywords.join([；])]
  } else {
    // The literal space after `Keywords:` in `thuthesis.dtx` follows a
    // colon. TeX's sentence-space glue for TeX Gyre Termes is
    // fontdimen2 + fontdimen7 = 1/4em + 1/12em = 1/3em.
    [#indent#strong[Keywords:]#h(1em / 3)#keywords.join([; ])]
  }
}

#let _abstract-zh(
  env,
  keywords: (),
  title: auto,
  header: auto,
  body,
) = _inside(env, config => {
  let names = chapter-names(config)
  let title = if title == auto { names.abstract-zh } else { title }
  (thuthesis-runtime.begin-special-heading)("abstract-zh", title, header)
  heading(
    level: 1,
    numbering: none,
    outlined: _front-title-outlined(config, "abstract"),
    title,
  )
  (thuthesis-runtime.end-special-heading)()
  set text(lang: "zh", region: "CN", font: serif-fonts(config))
  set par(linebreaks: "simple")
  body
  parbreak()
  v(bp(20))
  // Postdoc abstracts omit `\noindent`, retaining the 2em paragraph indent.
  block(_keyword-line(config, "chinese", keywords))
})

#let _abstract-en(
  env,
  keywords: (),
  title: auto,
  header: auto,
  body,
) = _inside(env, config => {
  let names = chapter-names(config)
  let title = if title == auto { names.abstract-en } else { title }
  (env.layout.heading-style)(variant: "english-special", {
    (thuthesis-runtime.begin-special-heading)("abstract-en", title, header)
    heading(
      level: 1,
      numbering: none,
      outlined: _front-title-outlined(config, "abstract"),
      title,
    )
    (thuthesis-runtime.end-special-heading)()
  })
  if config.degree == "bachelor" { v(bp(3)) }
  set text(lang: "en", region: none, font: serif-fonts(config))
  set par(linebreaks: "optimized")
  body
  parbreak()
  v(bp(20))
  // Postdoc abstracts omit `\noindent`, retaining the 2em paragraph indent.
  block(_keyword-line(config, "english", keywords))
})

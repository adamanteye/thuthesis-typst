#import "../config.typ": chapter-names
#import "../layouts/headings.typ": heading-style
#import "common.typ": front-title-outlined, special-chapter
#import "../utils/text.typ": bp

#let _keyword-line(config, zh, keywords) = {
  let postdoc = config.degree == "postdoc"
  let indent = if postdoc { h(2em) } else { [] }
  if zh {
    let label = if postdoc { strong[关键词：] } else {
      text(font: config.fonts.HeiTi, [关键词：])
    }
    [#indent#label#keywords.join([；])]
  } else {
    // TeX sentence space after colon for TeX Gyre Termes: 1/4em + 1/12em = 1/3em.
    [#indent#strong[Keywords:]#h(1em / 3)#keywords.join([; ])]
  }
}

#let _abstract(config, zh, keywords: (), title: auto, header: auto, body) = {
  let names = chapter-names(config)
  let title = if title == auto {
    if zh { names.abstract-zh } else { names.abstract-en }
  } else { title }
  let heading-block = special-chapter(
    title,
    outlined: front-title-outlined(config, "abstract"),
    header: header,
    kind: if zh { "abstract-zh" } else { "abstract-en" },
  )
  if zh { heading-block } else {
    heading-style(config, variant: "english-special", heading-block)
  }
  if not zh and config.degree == "bachelor" { v(bp(3)) }
  set text(
    lang: if zh { "zh" } else { "en" },
    region: if zh { "CN" } else { none },
    font: config.fonts.SongTi,
  )
  set par(linebreaks: if zh { "simple" } else { "optimized" })
  body
  parbreak()
  v(bp(20))
  block(_keyword-line(config, zh, keywords))
}

#let abstract-zh(config, ..args) = _abstract(config, true, ..args)
#let abstract-en(config, ..args) = _abstract(config, false, ..args)

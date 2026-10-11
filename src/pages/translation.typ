#import "bibliography.typ": _bibliography-thu

#let _chinese-content(body) = {
  set text(lang: "zh", region: "CN")
  set par(linebreaks: "simple")
  body
}

#let _english-content(body) = {
  set text(lang: "en", region: none)
  set par(linebreaks: "optimized")
  body
}

// Undergraduate survey and translation components retained for LaTeX parity.
#let _survey(body) = {
  heading(level: 1, [外文资料的调研阅读报告])
  _english-content(body)
}

#let _translation(body) = {
  heading(level: 1, [外文资料的书面翻译])
  _chinese-content(body)
}

#let _translation-index(
  env,
  sources,
  style: "numeric",
  full: true,
) = _bibliography-thu(
  env,
  sources,
  style: style,
  title: [书面翻译对应的原文索引],
  full: full,
)

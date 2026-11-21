#import "../config.typ": chinese
#import "../utils/text.typ": stretch-text

#let _english-chapter-words = (
  "Zero",
  "One",
  "Two",
  "Three",
  "Four",
  "Five",
  "Six",
  "Seven",
  "Eight",
  "Nine",
  "Ten",
  "Eleven",
  "Twelve",
  "Thirteen",
  "Fourteen",
  "Fifteen",
  "Sixteen",
  "Seventeen",
  "Eighteen",
  "Nineteen",
  "Twenty",
)

#let chapter-label(config, number, appendix: false) = if appendix {
  [#if chinese(config) [附录] else [APPENDIX]#text(" ")#number]
} else if chinese(config) {
  [第#text(" ")#number#text(" ")章]
} else if config.degree == "bachelor" {
  [Chapter#text(" ")#_english-chapter-words.at(int(number))]
} else {
  [CHAPTER#text(" ")#number]
}

#let render-title(
  config,
  body,
  kind: "body",
  outline: false,
  numbered: false,
) = {
  let zh = chinese(config)
  let spread = if kind == "abstract-zh" {
    3em
  } else if kind == "contents" and zh {
    if config.degree == "bachelor" { 2.5em } else if (
      config.degree == "postdoc"
    ) { 4em } else { 3em }
  } else if (
    config.degree != "bachelor"
      and (kind == "statement" or (kind == "acknowledgements" and zh))
  ) {
    3em
  } else if numbered and config.degree == "bachelor" and (zh or not outline) {
    3em
  }
  let body = if spread == none { body } else { stretch-text(spread, body) }
  if not zh and config.degree != "bachelor" { upper(body) } else { body }
}

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

#let chapter-label(config, number, appendix: false) = {
  if appendix {
    if chinese(config) {
      [附录]
      text(" ")
      number
    } else {
      [APPENDIX]
      text(" ")
      number
    }
  } else if chinese(config) {
    [第]
    text(" ")
    number
    text(" ")
    [章]
  } else if config.degree == "bachelor" {
    let value = int(number)
    [Chapter]
    text(" ")
    if value < _english-chapter-words.len() {
      _english-chapter-words.at(value)
    } else {
      panic(
        "thuthesis: English bachelor chapter names are defined only through Twenty",
      )
    }
  } else {
    [CHAPTER]
    text(" ")
    number
  }
}

// Resolve semantic title rules independently for every output target. The
// source heading stays logical text; only its visual projections add layout.
#let _title-rule(config, kind, target, numbered) = {
  let spread = if target == "bookmark" {
    none
  } else if target == "outline" and numbered {
    if config.degree == "bachelor" and chinese(config) {
      3em
    } else {
      none
    }
  } else if kind == "abstract-zh" {
    3em
  } else if kind == "contents" and chinese(config) {
    if config.degree == "bachelor" {
      2.5em
    } else if config.degree in ("master", "doctor") {
      3em
    } else {
      4em
    }
  } else if (
    config.degree != "bachelor"
      and (kind == "statement" or (kind == "acknowledgements" and chinese(config)))
  ) {
    3em
  } else if numbered and config.degree == "bachelor" and target != "outline" {
    3em
  } else {
    none
  }
  (
    spread: spread,
    uppercase: target != "bookmark"
      and not chinese(config)
      and config.degree != "bachelor",
  )
}

#let render-title(
  config,
  body,
  kind: "body",
  target: "heading",
  numbered: false,
) = {
  assert(
    target in ("heading", "header", "outline", "bookmark"),
    message: "thuthesis: invalid title render target",
  )
  let rule = _title-rule(config, kind, target, numbered)
  let body = if rule.spread == none {
    body
  } else {
    stretch-text(rule.spread, body)
  }
  if rule.uppercase { upper(body) } else { body }
}

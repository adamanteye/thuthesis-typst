// Configuration defaults, font presets, normalization, and localized names.

#import "utils/text.typ": plain-text

#let _font-base = (
  SongTi: ("TeX Gyre Termes", "FandolSong", "FandolKai"),
  HeiTi: ("TeX Gyre Heros", "FandolHei"),
  Mono: ("TeX Gyre Cursor", "FandolFang R"),
  FangSong: ("TeX Gyre Termes", "FandolFang R"),
  KaiTi: ("TeX Gyre Termes", "FandolKai"),
  Math: ("XITS Math",),
)

#let _font-presets = (
  fandol: _font-base,
  "auto": _font-base,
  linux: _font-base,
  ubuntu: _font-base
    + (
      SongTi: ("TeX Gyre Termes", "Noto Serif CJK SC", "FandolKai"),
      HeiTi: ("TeX Gyre Heros", "Noto Sans CJK SC"),
      Mono: ("TeX Gyre Cursor", "Noto Sans Mono CJK SC"),
    ),
  windows: _font-base
    + (
      SongTi: ("Times New Roman", "SimSun", "KaiTi"),
      HeiTi: ("Arial", "SimHei"),
      Mono: ("Courier New", "FangSong"),
      FangSong: ("Times New Roman", "FangSong"),
      KaiTi: ("Times New Roman", "KaiTi"),
    ),
  mac: _font-base
    + (
      SongTi: ("Times New Roman", "Songti SC", "Kaiti SC"),
      HeiTi: ("Arial", "Heiti SC"),
      Mono: ("Menlo", "STFangsong"),
      FangSong: ("Times New Roman", "STFangsong"),
      KaiTi: ("Times New Roman", "Kaiti SC"),
    ),
)

#let _person-fields = (
  "supervisor",
  "supervisor-en",
  "associate-supervisor",
  "associate-supervisor-en",
  "co-supervisor",
  "co-supervisor-en",
)

#let _blank-styles = ("no-header", "no-numbering", "no-content", "blank-only")

#let _defaults = (
  language: "chinese",
  thesis-type: "thesis",
  style-override: "none",
  math-style: "auto",
  include-spine: false,
  bibliography-style: "auto",
  open-right: false,
  eqn-paren-style: "auto",
  footnote-numbering: "page",
  footnote-style: "circled",
  figure-numbering: "chapter",
  table-numbering: "chapter",
  equation-numbering: "chapter",
  number-separator: ".",
  figure-number-separator: auto,
  table-number-separator: auto,
  equation-number-separator: auto,
  appendix-figure-in-list: false,
  spine-title: auto,
  spine-author: auto,
  spine-font: auto,
  use-latexref: false,
  latexref-prefixes: ("fig:", "tbl:", "eqt:", "lst:", "img:", "alg:"),
  unnumbered-label: "-",
  use-fakebold: false,
  subfig-numbering: "(a)",
  subfig-numbering-extended: true,
  subfig-outlined: true,
)

#let _resolve-fonts(spec) = {
  let raw = if spec == (:) {
    _font-base
  } else if type(spec) == str {
    _font-presets.at(spec)
  } else {
    _font-base + spec
  }
  raw
    .pairs()
    .map(((k, v)) => (k, if type(v) == str { (v,) } else { v }))
    .to-dict()
}

#let _normalize-info(info, anonymous) = {
  for (old, new) in (
    ("major", "discipline"),
    ("major-en", "discipline-en"),
    ("degree-name", "degree-category"),
    ("degree-name-en", "degree-category-en"),
  ) {
    if old in info { info.insert(new, info.remove(old)) }
  }
  for key in ("title", "title-en") {
    let title = info.at(key, default: none)
    if type(title) == str and title.contains("\n") { title = title.split("\n") }
    if type(title) == array { info.insert(key, title.join(linebreak())) }
  }
  for key in _person-fields {
    let person = info.at(key, default: none)
    if key in info and person in (none, ()) {
      let _ = info.remove(key)
    } else if type(person) == array {
      info.insert(key, (
        name: person.first(),
        title: person.at(1, default: none),
      ))
    }
  }
  if anonymous {
    for key in ("author", "author-en") {
      if key in info { info.insert(key, []) }
    }
    for key in _person-fields {
      if key in info { info.insert(key, (name: [], title: none)) }
    }
  }
  info
}

#let build-config(
  degree,
  degree-type,
  anonymous,
  twoside,
  fonts,
  info,
  bibliography,
  extra,
) = {
  let font-spec = extra.at("font-profile", default: fonts)
  let opts = (
    _defaults
      + (
        degree: degree,
        degree-type: degree-type,
        anonymous: anonymous,
        output: if twoside in (false, "false") { "electronic" } else {
          "print"
        },
        blank-page-style: if twoside in _blank-styles { twoside } else {
          "no-content"
        },
        bibliography: bibliography,
      )
      + extra
  )
  let info = _normalize-info(info, opts.anonymous)
  let zh = opts.language == "chinese"
  let schwarzman = opts.style-override == "schwarzman"
  let meta-val(key, src, fallback) = info.at(key, default: {
    let v = plain-text(info.at(src, default: none))
    if v == none { fallback } else { v }
  })
  let subject = if opts.degree == "postdoc" {
    none
  } else {
    plain-text(info.at(
      if zh or opts.degree == "bachelor" { "discipline" } else {
        "discipline-en"
      },
      default: info.at("discipline", default: none),
    ))
  }
  let sep = opts.number-separator
  (
    opts
      + (
        fonts: _resolve-fonts(font-spec),
        info: info,
        metadata: (
          title: meta-val("metadata-title", "title", "Thesis"),
          author: if opts.anonymous { "" } else {
            meta-val("metadata-author", "author", "Author")
          },
          subject: subject,
        ),
        math-style: if opts.math-style == "auto" {
          if zh { "GB" } else { "TeX" }
        } else { opts.math-style },
        bibliography-style: if bibliography != none {
          bibliography.citation-style
        } else if opts.bibliography-style == "auto" {
          "numeric"
        } else {
          opts.bibliography-style
        },
        eqn-paren-style: if opts.eqn-paren-style == "auto" {
          if zh { "full" } else { "half" }
        } else {
          opts.eqn-paren-style
        },
        footnote-numbering: if schwarzman { "global" } else {
          opts.footnote-numbering
        },
        footnote-style: if schwarzman { "plain" } else { opts.footnote-style },
        figure-numbering: if schwarzman { "global" } else {
          opts.figure-numbering
        },
        table-numbering: if schwarzman { "global" } else {
          opts.table-numbering
        },
        equation-numbering: if schwarzman { "global" } else {
          opts.equation-numbering
        },
        figure-number-separator: if opts.figure-number-separator == auto {
          sep
        } else { opts.figure-number-separator },
        table-number-separator: if opts.table-number-separator == auto {
          sep
        } else { opts.table-number-separator },
        equation-number-separator: if opts.equation-number-separator == auto {
          sep
        } else {
          opts.equation-number-separator
        },
      )
  )
}

#let is-graduate(config) = config.degree in ("master", "doctor")
#let chinese(config) = config.language == "chinese"
#let localized(config, zh, en) = if chinese(config) { zh } else { en }

#let chapter-names(config) = {
  let shared = (statement: "声明", abstract-zh: "摘要", abstract-en: "Abstract")
  if chinese(config) {
    (
      shared
        + (
          contents: if config.degree == "postdoc" { "目次" } else { "目录" },
          figures: "插图清单",
          tables: "附表清单",
          figures-tables: "插图和附表清单",
          equations: if config.degree == "bachelor" { "公式索引" } else {
            "公式清单"
          },
          denotation: if config.degree == "postdoc" { "符号表" } else {
            "符号和缩略语说明"
          },
          bibliography: "参考文献",
          acknowledgements: "致谢",
          resume: if config.degree == "bachelor" {
            "在学期间参加课题的研究成果"
          } else if config.degree == "postdoc" {
            "个人简历、发表的学术论文与科研成果"
          } else {
            "个人简历、在学期间完成的相关学术成果"
          },
          comments: "指导教师评语",
          resolution: "答辩委员会决议书",
        )
    )
  } else {
    let en-shared = (
      shared
        + (
          comments: "Comments from Thesis Supervisor",
          resolution: "Resolution of Thesis Defense Committee",
        )
    )
    if config.degree == "bachelor" {
      (
        en-shared
          + (
            contents: "CONTENTS",
            figures: "FIGURES",
            tables: "TABLES",
            figures-tables: "FIGURES AND TABLES",
            equations: "EQUATIONS",
            denotation: "ABBREVIATIONS",
            bibliography: "REFERENCES",
            acknowledgements: "ACKNOWLEDGEMENTS",
            resume: "PUBLICATIONS",
          )
      )
    } else {
      (
        en-shared
          + (
            contents: "Table of Contents",
            figures: "List of Figures",
            tables: "List of Tables",
            figures-tables: "List of Figures and Tables",
            equations: "List of Equations",
            denotation: "List of Symbols and Acronyms",
            bibliography: "References",
            acknowledgements: "Acknowledgements",
            resume: "Resume",
          )
      )
    }
  }
}

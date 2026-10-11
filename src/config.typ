// Configuration schema, validation, normalization, and localized names.

#let _degrees = ("bachelor", "master", "doctor", "postdoc")
#let _degree-types = ("academic", "professional")
#let _languages = ("chinese", "english")
#let _outputs = ("print", "electronic")
#let _thesis-types = ("thesis", "proposal")
#let _style-overrides = ("none", "schwarzman")
#let _numbering-scopes = ("page", "chapter", "global")
#let _font-roles = ("serif", "sans", "mono", "fangsong", "kaiti", "math")

// Keep shared font data in one place. Platform profiles only override the
// roles that differ from this deterministic TeX Live base.
#let _font-base = (
  serif: ("TeX Gyre Termes", "FandolSong", "FandolKai"),
  sans: ("TeX Gyre Heros", "FandolHei"),
  mono: ("TeX Gyre Cursor", "FandolFang R"),
  fangsong: ("TeX Gyre Termes", "FandolFang R"),
  kaiti: ("TeX Gyre Termes", "FandolKai"),
  math: ("XITS Math",),
)

#let font-profiles = (
  fandol: _font-base,
  ubuntu: _font-base
    + (
      serif: ("TeX Gyre Termes", "Noto Serif CJK SC", "FandolKai"),
      sans: ("TeX Gyre Heros", "Noto Sans CJK SC"),
      mono: ("TeX Gyre Cursor", "Noto Sans Mono CJK SC"),
    ),
  windows: _font-base
    + (
      serif: ("Times New Roman", "SimSun", "KaiTi"),
      sans: ("Arial", "SimHei"),
      mono: ("Courier New", "FangSong"),
      fangsong: ("Times New Roman", "FangSong"),
      kaiti: ("Times New Roman", "KaiTi"),
    ),
  mac: _font-base
    + (
      serif: ("Times New Roman", "Songti SC", "Kaiti SC"),
      sans: ("Arial", "Heiti SC"),
      mono: ("Menlo", "STFangsong"),
      fangsong: ("Times New Roman", "STFangsong"),
      kaiti: ("Times New Roman", "Kaiti SC"),
    ),
)

// `auto` and `linux` are accepted preset names, but are not public profiles.
#let _font-presets = (
  font-profiles
    + (
      "auto": font-profiles.fandol,
      linux: font-profiles.fandol,
    )
)

#let _defaults = (
  degree: "doctor",
  degree-type: "academic",
  language: "chinese",
  output: "print",
  thesis-type: "thesis",
  style-override: "none",
  font-profile: "auto",
  math-style: "auto",
  info: (:),
  include-spine: false,
  bibliography-style: "auto",
  bibliography: none,
  open-right: false,
  ragged-bottom: true,
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
  // Compatibility options retained from TnTT 0.5.x.  They are disabled by
  // default so the LaTeX-aligned baseline is unaffected.
  anonymous: false,
  blank-page-style: "no-content",
  use-latexref: false,
  latexref-prefixes: ("fig:", "tbl:", "eqt:", "lst:", "img:", "alg:"),
  unnumbered-label: "-",
  use-fakebold: false,
  subfig-numbering: "(a)",
  subfig-numbering-extended: true,
  subfig-outlined: true,
)

#let _known-info = (
  "title",
  "title-en",
  "author",
  "author-en",
  "date",
  "metadata-title",
  "metadata-author",
  "department",
  "degree-category",
  "degree-category-en",
  "discipline",
  "discipline-en",
  "professional-field",
  "professional-field-en",
  "engineering-field",
  "student-id",
  "supervisor",
  "supervisor-en",
  "associate-supervisor",
  "associate-supervisor-en",
  "co-supervisor",
  "co-supervisor-en",
  "secret-level",
  "secret-year",
  "clc",
  "udc",
  "id",
  "discipline-level-1",
  "discipline-level-2",
  "start-date",
  "end-date",
)

#let _common-info = (
  "title",
  "author",
  "date",
  "metadata-title",
  "metadata-author",
  "secret-level",
  "secret-year",
)
#let _bachelor-info = (
  "title-en",
  "department",
  "discipline",
  "supervisor",
  "associate-supervisor",
  "co-supervisor",
)
#let _graduate-info = (
  "title-en",
  "author-en",
  "department",
  "degree-category",
  "degree-category-en",
  "discipline",
  "discipline-en",
  "professional-field",
  "professional-field-en",
  "engineering-field",
  "student-id",
  "supervisor",
  "supervisor-en",
  "associate-supervisor",
  "associate-supervisor-en",
  "co-supervisor",
  "co-supervisor-en",
)
#let _postdoc-info = (
  "title-en",
  "clc",
  "udc",
  "id",
  "discipline-level-1",
  "discipline-level-2",
  "start-date",
  "end-date",
)
#let _person-fields = (
  "supervisor",
  "supervisor-en",
  "associate-supervisor",
  "associate-supervisor-en",
  "co-supervisor",
  "co-supervisor-en",
)

#let _choice(name, value, choices) = assert(
  value in choices,
  message: "thuthesis: invalid "
    + name
    + " `"
    + str(value)
    + "`; expected one of "
    + choices.join(", "),
)

#let _plain-text(value, default: none) = if type(value) == str {
  value
} else if type(value) == content {
  value.fields().at("text", default: default)
} else {
  default
}

#let _nonempty-text(value) = if type(value) == str {
  value.trim() != ""
} else if type(value) == content {
  (
    value != []
      and {
        let plain = _plain-text(value)
        plain == none or plain.trim() != ""
      }
  )
} else {
  false
}

#let _require-text(info, key) = {
  assert(
    key in info,
    message: "thuthesis: missing required info field `" + key + "`",
  )
  assert(
    _nonempty-text(info.at(key)),
    message: "thuthesis: info field `" + key + "` must be non-empty text",
  )
}

#let _validate-optional-text(info, key) = if key in info {
  assert(
    _nonempty-text(info.at(key)),
    message: "thuthesis: info field `" + key + "` must be non-empty text",
  )
}

#let _validate-person(info, key, required: false) = {
  if required {
    assert(
      key in info,
      message: "thuthesis: missing required info field `" + key + "`",
    )
  }
  if key in info {
    let person = info.at(key)
    assert(
      type(person) == dictionary,
      message: "thuthesis: info field `"
        + key
        + "` must be `(name: ..., title: ...)`",
    )
    for field in person.keys() {
      assert(
        field in ("name", "title"),
        message: "thuthesis: unknown field `" + field + "` in `" + key + "`",
      )
    }
    assert(
      "name" in person and "title" in person,
      message: "thuthesis: info field `"
        + key
        + "` must contain `name` and `title`",
    )
    assert(
      _nonempty-text(person.name),
      message: "thuthesis: `" + key + ".name` must be non-empty text",
    )
    assert(
      person.title == none or _nonempty-text(person.title),
      message: "thuthesis: `"
        + key
        + ".title` must be non-empty text or `none`",
    )
  }
}

#let _validate-date(info, key, required: false) = {
  if required {
    assert(
      key in info,
      message: "thuthesis: missing required info field `" + key + "`",
    )
  }
  if key in info {
    let value = info.at(key)
    assert(
      type(value) == datetime,
      message: "thuthesis: `" + key + "` must use datetime(...)",
    )
    assert(
      value.year() != none and value.month() != none and value.day() != none,
      message: "thuthesis: `" + key + "` must be a complete calendar date",
    )
  }
}

#let _date-key(value) = (
  value.year() * 10000 + value.month() * 100 + value.day()
)

#let _font-list(role, value) = {
  let fonts = if type(value) == str { (value,) } else { value }
  assert(
    type(fonts) == array and fonts.len() > 0,
    message: "thuthesis: font role `"
      + role
      + "` must be a font name or a non-empty array",
  )
  for font in fonts {
    let name = if type(font) == dictionary { font.at("name", default: none) } else { font }
    assert(
      type(name) == str and name.trim() != "",
      message: "thuthesis: every font in role `"
        + role
        + "` must be a font name or a font dictionary with a name",
    )
  }
  fonts
}

#let _resolve-font-profile(profile) = {
  let value = if type(profile) == str {
    _choice("font-profile", profile, _font-presets.keys())
    _font-presets.at(profile)
  } else {
    assert(
      type(profile) == dictionary,
      message: "thuthesis: `font-profile` must be a preset name or a dictionary",
    )
    profile
  }
  for role in value.keys() {
    assert(
      role in _font-roles,
      message: "thuthesis: unknown font role `" + role + "`",
    )
  }
  for role in _font-roles {
    assert(
      role in value,
      message: "thuthesis: font profile is missing role `" + role + "`",
    )
  }
  (
    serif: _font-list("serif", value.serif),
    sans: _font-list("sans", value.sans),
    mono: _font-list("mono", value.mono),
    fangsong: _font-list("fangsong", value.fangsong),
    kaiti: _font-list("kaiti", value.kaiti),
    math: _font-list("math", value.math),
  )
}

#let _metadata-value(info, key, source, fallback) = if key in info {
  let value = info.at(key)
  assert(
    type(value) == str,
    message: "thuthesis: `" + key + "` must be a string",
  )
  value
} else {
  let value = _plain-text(info.at(source))
  if value == none { fallback } else { value }
}

#let _metadata-subject(info, language) = {
  let source = if language == "chinese" { "discipline" } else {
    "discipline-en"
  }
  if source in info {
    _plain-text(info.at(source))
  } else if "discipline" in info {
    _plain-text(info.discipline)
  } else {
    none
  }
}

#let _applicable-info(degree) = (
  _common-info
    + if degree == "bachelor" {
      _bachelor-info
    } else if degree in ("master", "doctor") {
      _graduate-info
    } else {
      _postdoc-info
    }
)

#let _normalize-info(options) = {
  let info = options.info
  assert(
    type(info) == dictionary,
    message: "thuthesis: `info` must be a dictionary",
  )
  for key in info.keys() {
    assert(
      key in _known-info,
      message: "thuthesis: unknown info field `" + key + "`",
    )
  }

  let degree = options.degree
  let applicable = _applicable-info(degree)
  let normalized = (:)
  for key in applicable {
    if key in info { normalized.insert(key, info.at(key)) }
  }

  for key in normalized.keys() {
    if (
      key not in _person-fields
        and key
          not in (
            "date",
            "start-date",
            "end-date",
            "secret-year",
          )
    ) {
      _validate-optional-text(normalized, key)
    }
  }
  if "secret-year" in normalized {
    assert(
      type(normalized.at("secret-year")) == int
        and normalized.at("secret-year") >= 0,
      message: "thuthesis: `secret-year` must be a non-negative integer",
    )
  }

  _require-text(normalized, "title")
  _require-text(normalized, "author")
  _validate-date(normalized, "date", required: true)

  if degree == "bachelor" {
    for key in ("department", "discipline") { _require-text(normalized, key) }
    _validate-person(normalized, "supervisor", required: true)
    for key in ("associate-supervisor", "co-supervisor") {
      _validate-person(normalized, key)
    }
    if options.language == "english" { _require-text(normalized, "title-en") }
  } else if degree in ("master", "doctor") {
    for key in ("department", "degree-category") {
      _require-text(normalized, key)
    }
    _validate-person(normalized, "supervisor", required: true)
    for key in (
      "supervisor-en",
      "associate-supervisor",
      "associate-supervisor-en",
      "co-supervisor",
      "co-supervisor-en",
    ) { _validate-person(normalized, key) }
    if options.degree-type == "academic" {
      _require-text(normalized, "discipline")
    } else {
      _require-text(normalized, "professional-field")
    }
    if options.thesis-type == "thesis" {
      for key in ("title-en", "author-en", "degree-category-en") {
        _require-text(normalized, key)
      }
      _validate-person(normalized, "supervisor-en", required: true)
      if options.degree-type == "academic" {
        _require-text(normalized, "discipline-en")
      }
    } else {
      _require-text(normalized, "student-id")
    }
  } else {
    for key in ("title-en", "discipline-level-1", "discipline-level-2") {
      _require-text(normalized, key)
    }
    _validate-date(normalized, "start-date", required: true)
    _validate-date(normalized, "end-date", required: true)
    assert(
      _date-key(normalized.at("start-date"))
        <= _date-key(normalized.at("end-date")),
      message: "thuthesis: `start-date` must not be later than `end-date`",
    )
  }
  // Keep the cover geometry while removing identifying information. This is
  // deliberately applied after validation: anonymous submissions still use
  // the normal complete metadata schema at source level.
  if options.anonymous {
    for key in ("author", "author-en") {
      if key in normalized { normalized.insert(key, []) }
    }
    for key in _person-fields {
      if key in normalized { normalized.insert(key, (name: [], title: none)) }
    }
  }
  normalized
}

#let page-options(degree, degree-type, anonymous, twoside, fonts, info, bibliography, options) = {
  import "utils/font.typ": page-font-profile
  let blank-styles = ("no-header", "no-numbering", "no-content", "blank-only")
  assert(twoside in (true, false, "true", "false") + blank-styles, message: "Invalid twoside setting")
  // Keep the page API's title lines, cover labels and (name, title) pairs.
  for (old, new) in (
    ("major", "discipline"), ("major-en", "discipline-en"),
    ("degree-name", "degree-category"), ("degree-name-en", "degree-category-en"),
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
      assert(person.len() in (1, 2), message: key + " requires a name and an optional title")
      info.insert(key, (name: person.first(), title: person.at(1, default: none)))
    }
  }
  let profile = if fonts == (:) { "fandol" } else if type(fonts) == str { fonts } else { page-font-profile(fonts) }
  arguments(
    degree: degree,
    degree-type: degree-type,
    anonymous: anonymous,
    info: info,
    output: if twoside in (false, "false") { "electronic" } else { "print" },
    blank-page-style: if twoside in blank-styles { twoside } else { "no-content" },
    font-profile: profile,
    bibliography: bibliography,
    ..options,
  )
}

#let normalize(args) = {
  assert(
    type(args) == arguments,
    message: "thuthesis: internal configuration arguments are invalid",
  )
  assert(
    args.pos().len() == 0,
    message: "thuthesis: all configuration options must be named",
  )
  let supplied = args.named()
  for key in supplied.keys() {
    assert(
      key in _defaults,
      message: "thuthesis: unknown option `" + key + "`",
    )
  }
  let options = _defaults + supplied

  _choice("degree", options.degree, _degrees)
  _choice("degree-type", options.degree-type, _degree-types)
  _choice("language", options.language, _languages)
  _choice("output", options.output, _outputs)
  _choice("thesis-type", options.thesis-type, _thesis-types)
  _choice("style-override", options.style-override, _style-overrides)
  _choice("math-style", options.math-style, ("auto", "GB", "ISO", "TeX"))
  _choice("bibliography-style", options.bibliography-style, (
    "auto",
    "numeric",
    "author-year",
    "bachelor",
  ))
  _choice("eqn-paren-style", options.eqn-paren-style, (
    "auto",
    "full",
    "half",
  ))
  _choice("footnote-numbering", options.footnote-numbering, _numbering-scopes)
  _choice("footnote-style", options.footnote-style, ("circled", "plain"))
  _choice("figure-numbering", options.figure-numbering, ("chapter", "global"))
  _choice("table-numbering", options.table-numbering, ("chapter", "global"))
  _choice("equation-numbering", options.equation-numbering, (
    "chapter",
    "global",
  ))

  for (name, value) in (
    ("include-spine", options.include-spine),
    ("open-right", options.open-right),
    ("ragged-bottom", options.ragged-bottom),
    ("appendix-figure-in-list", options.appendix-figure-in-list),
    ("anonymous", options.anonymous),
    ("use-latexref", options.use-latexref),
    ("use-fakebold", options.use-fakebold),
    ("subfig-numbering-extended", options.subfig-numbering-extended),
    ("subfig-outlined", options.subfig-outlined),
  ) {
    assert(
      type(value) == bool,
      message: "thuthesis: `" + name + "` must be a boolean",
    )
  }
  for (name, value) in (
    ("number-separator", options.number-separator),
    ("figure-number-separator", options.figure-number-separator),
    ("table-number-separator", options.table-number-separator),
    ("equation-number-separator", options.equation-number-separator),
  ) {
    assert(
      value == auto or (type(value) == str and value != ""),
      message: "thuthesis: `"
        + name
        + "` must be a non-empty string or `auto`",
    )
  }
  for (name, value) in (
    ("spine-title", options.spine-title),
    ("spine-author", options.spine-author),
  ) {
    assert(
      value == auto or _nonempty-text(value),
      message: "thuthesis: `" + name + "` must be non-empty text or `auto`",
    )
  }
  assert(
    options.spine-font == auto
      or (type(options.spine-font) == length and options.spine-font > 0pt),
    message: "thuthesis: `spine-font` must be a positive length or `auto`",
  )
  _choice("blank-page-style", options.blank-page-style, (
    "no-header",
    "no-numbering",
    "no-content",
    "blank-only",
  ))
  assert(
    options.unnumbered-label == none or type(options.unnumbered-label) == str,
    message: "thuthesis: `unnumbered-label` must be a string or `none`",
  )
  assert(
    type(options.subfig-numbering) == str or options.subfig-numbering == none,
    message: "thuthesis: `subfig-numbering` must be a string or `none`",
  )
  assert(
    type(options.latexref-prefixes) == array
      and options.latexref-prefixes.all(it => type(it) == str),
    message: "thuthesis: `latexref-prefixes` must be an array of strings",
  )
  assert(
    options.ragged-bottom,
    message: "thuthesis: Typst currently supports only `ragged-bottom: true`",
  )
  assert(
    not (options.degree == "postdoc" and options.thesis-type == "proposal"),
    message: "thuthesis: postdoctoral reports do not support `thesis-type: proposal`",
  )
  assert(
    not (
      options.style-override == "schwarzman"
        and options.degree not in ("master", "doctor")
    ),
    message: "thuthesis: the Schwarzman override is only available for graduate theses",
  )
  assert(
    not (
      options.degree == "bachelor"
        and options.include-spine
        and options.spine-font == auto
    ),
    message: "thuthesis: bachelor spines require an explicit `spine-font` size",
  )

  let info = _normalize-info(options)
  let schwarzman = options.style-override == "schwarzman"
  (
    options
      + (
        font-profile: _resolve-font-profile(options.font-profile),
        math-style: if options.math-style == "auto" {
          if options.language == "chinese" { "GB" } else { "TeX" }
        } else { options.math-style },
        info: info,
        metadata: (
          title: _metadata-value(info, "metadata-title", "title", "Thesis"),
          author: if options.anonymous { "" } else {
            _metadata-value(info, "metadata-author", "author", "Author")
          },
          subject: _metadata-subject(info, options.language),
        ),
        include-spine: options.include-spine,
        bibliography-style: if options.bibliography-style == "auto" {
          if options.degree == "bachelor" { "bachelor" } else { "numeric" }
        } else { options.bibliography-style },
        eqn-paren-style: if options.eqn-paren-style == "auto" {
          if options.language == "chinese" { "full" } else { "half" }
        } else { options.eqn-paren-style },
        footnote-numbering: if schwarzman { "global" } else {
          options.footnote-numbering
        },
        footnote-style: if schwarzman { "plain" } else {
          options.footnote-style
        },
        figure-numbering: if schwarzman { "global" } else {
          options.figure-numbering
        },
        table-numbering: if schwarzman { "global" } else {
          options.table-numbering
        },
        equation-numbering: if schwarzman { "global" } else {
          options.equation-numbering
        },
        figure-number-separator: if options.figure-number-separator == auto {
          options.number-separator
        } else { options.figure-number-separator },
        table-number-separator: if options.table-number-separator == auto {
          options.number-separator
        } else { options.table-number-separator },
        equation-number-separator: if options.equation-number-separator
          == auto {
          options.number-separator
        } else { options.equation-number-separator },
      )
  )
}

#let info-at(config, key, default: none) = config.info.at(
  key,
  default: default,
)
#let is-graduate(config) = config.degree in ("master", "doctor")
#let chinese(config) = config.language == "chinese"
#let localized(config, zh, en) = if chinese(config) { zh } else { en }

#let serif-fonts(config) = config.font-profile.serif
#let sans-fonts(config) = config.font-profile.sans
#let fangsong-fonts(config) = config.font-profile.fangsong
#let mono-fonts(config) = config.font-profile.mono
#let math-fonts(config) = config.font-profile.math

#let chapter-names(config) = if chinese(config) {
  (
    contents: if config.degree == "postdoc" { "目次" } else { "目录" },
    figures: "插图清单",
    tables: "附表清单",
    figures-tables: "插图和附表清单",
    algorithms: "算法清单",
    equations: if config.degree == "bachelor" { "公式索引" } else {
      "公式清单"
    },
    denotation: if config.degree == "postdoc" { "符号表" } else {
      "符号和缩略语说明"
    },
    bibliography: "参考文献",
    acknowledgements: "致谢",
    statement: "声明",
    resume: if config.degree == "bachelor" {
      "在学期间参加课题的研究成果"
    } else if config.degree == "postdoc" {
      "个人简历、发表的学术论文与科研成果"
    } else { "个人简历、在学期间完成的相关学术成果" },
    comments: "指导教师评语",
    resolution: "答辩委员会决议书",
    abstract-zh: "摘要",
    abstract-en: "Abstract",
    appendix: "附录",
  )
} else if config.degree == "bachelor" {
  (
    contents: "CONTENTS",
    figures: "FIGURES",
    tables: "TABLES",
    figures-tables: "FIGURES AND TABLES",
    algorithms: "ALGORITHMS",
    equations: "EQUATIONS",
    denotation: "ABBREVIATIONS",
    bibliography: "REFERENCES",
    acknowledgements: "ACKNOWLEDGEMENTS",
    statement: "声明",
    resume: "PUBLICATIONS",
    comments: "Comments from Thesis Supervisor",
    resolution: "Resolution of Thesis Defense Committee",
    abstract-zh: "摘要",
    abstract-en: "Abstract",
    appendix: "APPENDIX",
  )
} else {
  (
    contents: "Table of Contents",
    figures: "List of Figures",
    tables: "List of Tables",
    figures-tables: "List of Figures and Tables",
    algorithms: "List of Algorithms",
    equations: "List of Equations",
    denotation: "List of Symbols and Acronyms",
    bibliography: "References",
    acknowledgements: "Acknowledgements",
    statement: "声明",
    resume: "Resume",
    comments: "Comments from Thesis Supervisor",
    resolution: "Resolution of Thesis Defense Committee",
    abstract-zh: "摘要",
    abstract-en: "Abstract",
    appendix: "Appendix",
  )
}

#import "../config.typ": fangsong-fonts
#import "../utils/people.typ": bachelor-person, graduate-person
#import "../utils/text.typ": bp, distribute, tex-pt

#let _row(label, value, person: false) = if value != none {
  (label: label, value: value, person: person)
}

#let _graduate-info(config) = {
  let info = config.info
  // Unlike the postdoc named-size forms, thuthesis.dtx:4614,4619 write
  // `\fontsize{16bp}{31.2bp}` literally, so this baseline remains direct.
  let font-size = bp(16)
  let baseline = bp(31.2)
  let rows = (
    _row("培养单位", info.at("department", default: none)),
    _row(
      if config.degree-type == "academic" { "学科" } else { "专业领域" },
      if config.degree-type == "academic" {
        info.at("discipline", default: none)
      } else {
        info.at("professional-field", default: none)
      },
    ),
    if config.degree-type == "professional" {
      _row("工程领域", info.at("engineering-field", default: none))
    },
    _row(
      if config.degree-type == "academic" { "研究生" } else { "申请人" },
      info.at("author", default: none),
      person: true,
    ),
    if config.thesis-type == "proposal" {
      _row("学号", info.at("student-id", default: none))
    },
    _row("指导教师", info.at("supervisor", default: none), person: true),
    _row(
      "副指导教师",
      info.at("associate-supervisor", default: none),
      person: true,
    ),
    _row(
      "联合指导教师",
      info.at("co-supervisor", default: none),
      person: true,
    ),
  ).filter(it => it != none)
  // LaTeX's `tabular` inserts an array strut whose height and depth are
  // respectively 0.7 and 0.3 of the 31.2bp baseline.  Model the row around
  // that baseline instead of centring 16bp ink in an equally padded cell.
  let row-ascent = 0.7 * baseline
  let row-descent = 0.3 * baseline
  let cell = body => pad(
    top: row-ascent - 0.8 * font-size,
    bottom: row-descent - 0.2 * font-size,
    body,
  )
  // The tabular used by LaTeX retains one 6pt `tabcolsep` at its left edge.
  box(width: 100%, pad(left: 2.3cm + tex-pt(6), grid(
    columns: (2.85cm, 0.77cm, 1fr),
    column-gutter: 0pt,
    row-gutter: 0pt,
    ..rows
      .map(row => (
        cell(box(width: 2.85cm, align(left, distribute(
          2.75cm,
          row.label,
          shrink: true,
        )))),
        cell(box(width: 0.77cm, align(left, [：]))),
        cell(if row.person { graduate-person(row.value) } else { row.value }),
      ))
      .flatten(),
  )))
}

#let _bachelor-info(config) = {
  let info = config.info
  let size = bp(16)
  let baseline = bp(20)
  let row-height = baseline * 1.548
  let co-supervisor = info.at("co-supervisor", default: none)
  let label-width = if co-supervisor != none { bp(86) } else { bp(79.35) }
  let label-text-width = if co-supervisor != none { 5em } else { 4em }
  let rows = (
    _row("系别", info.at("department", default: none)),
    _row("专业", info.at("discipline", default: none)),
    _row("姓名", info.at("author", default: none), person: true),
    _row("指导教师", info.at("supervisor", default: none), person: true),
    _row(
      "副指导教师",
      info.at("associate-supervisor", default: none),
      person: true,
    ),
    _row("联合指导教师", co-supervisor, person: true),
  ).filter(it => it != none)
  // LaTeX's array strut puts 70% of the stretched 20bp baseline above each
  // row baseline and 30% below it. Keep that asymmetry: symmetric padding
  // preserves row height but moves every text baseline.
  let cell = body => pad(
    top: 0.7 * row-height - 0.8 * size,
    bottom: 0.3 * row-height - 0.2 * size,
    body,
  )
  set text(
    font: fangsong-fonts(config),
    size: size,
    top-edge: 0.8em,
    bottom-edge: -0.2em,
  )
  grid(
    columns: (label-width, bp(23.25), bp(159.4)),
    column-gutter: 0pt,
    row-gutter: 0pt,
    ..rows
      .map(row => (
        cell(box(width: label-width, align(center, distribute(
          label-text-width,
          row.label,
          shrink: true,
        )))),
        // An isolated full-width colon is compressed at both CJK line
        // edges by Typst. Give it an explicit em box before centring it,
        // matching TeX's full-width punctuation box.
        cell(box(width: bp(23.25), align(center, box(
          width: 1em,
          align(left, [：]),
        )))),
        cell(box(
          width: bp(159.4),
          align(left, if row.person {
            bachelor-person(row.value)
          } else {
            row.value
          }),
        )),
      ))
      .flatten(),
  )
}

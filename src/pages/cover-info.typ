#import "../utils/people.typ": bachelor-person, graduate-person
#import "../utils/text.typ": array-cell, bp, distribute, tex-pt

#let _row(label, value, person: false) = if value != none {
  (label: label, value: value, person: person)
}

#let graduate-info(config) = {
  let info = config.info
  let size = bp(16)
  let baseline = bp(31.2)
  let academic = config.degree-type == "academic"
  let rows = (
    _row("培养单位", info.at("department", default: none)),
    _row(
      if academic { "学科" } else { "专业领域" },
      info.at(
        if academic { "discipline" } else { "professional-field" },
        default: none,
      ),
    ),
    if not academic {
      _row("工程领域", info.at("engineering-field", default: none))
    },
    _row(
      if academic { "研究生" } else { "申请人" },
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
    _row("联合指导教师", info.at("co-supervisor", default: none), person: true),
  ).filter(it => it != none)
  let cell(body) = array-cell(size, baseline, body)
  box(width: 100%, pad(left: 2.3cm + tex-pt(6), grid(
    columns: (2.85cm, 0.77cm, 1fr),
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

#let bachelor-info(config) = {
  let info = config.info
  let size = bp(16)
  let row-height = bp(20) * 1.548
  let co-sup = info.at("co-supervisor", default: none)
  let label-w = if co-sup != none { bp(86) } else { bp(79.35) }
  let label-text-w = if co-sup != none { 5em } else { 4em }
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
    _row("联合指导教师", co-sup, person: true),
  ).filter(it => it != none)
  let cell(body) = array-cell(size, row-height, body)
  set text(
    font: config.fonts.FangSong,
    size: size,
    top-edge: 0.8em,
    bottom-edge: -0.2em,
  )
  grid(
    columns: (label-w, bp(23.25), bp(159.4)),
    ..rows
      .map(row => (
        cell(box(width: label-w, align(center, distribute(
          label-text-w,
          row.label,
          shrink: true,
        )))),
        cell(box(width: bp(23.25), align(center, box(width: 1em, align(
          left,
          [：],
        ))))),
        cell(box(width: bp(159.4), align(left, if row.person {
          bachelor-person(row.value)
        } else { row.value }))),
      ))
      .flatten(),
  )
}

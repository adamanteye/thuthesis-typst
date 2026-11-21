#import "common.typ": cover-page
#import "../utils/dates.typ": date-zh-digits
#import "../utils/text.typ": (
  array-cell, bp, distribute, ink-ascent, line-height, stretch, tex-pt,
)

#let _postdoc-line(size, body) = block(
  width: 100%,
  height: size,
  align(center, text(size: size, top-edge: 0.8em, bottom-edge: -0.2em, body)),
)

#let _underline-box(width, size, dy, stroke, body) = box(
  width: width,
  height: size,
  baseline: 0.8 * size,
  {
    place(top + left, dy: dy, line(length: 100%, stroke: stroke))
    move(dy: -0.8 * size, block(width: 100%, align(top + center, body)))
  },
)

#let postdoc-cover(config) = cover-page(3cm, {
  let info = config.info
  let meta-size = bp(14)
  let meta-base = meta-size * 2.6
  let head-size = bp(18)
  let head-base = head-size * 2.6
  let title-size = bp(14)
  let title-base = title-size * 3.46
  let body-size = bp(12)
  let date-base = body-size * 1.58
  let inst-base = body-size * 2
  // TeX primitive `\underline` uses XITS Math's 0.198em gap and 0.066em rule.
  let meta-ul(v) = _underline-box(
    3.7cm,
    meta-size,
    0.231 * meta-size,
    0.066 * meta-size,
    v,
  )
  let date-ul(v) = _underline-box(
    5.9cm,
    body-size,
    0.9 * body-size,
    tex-pt(0.7),
    v,
  )
  let top-line(label, value, cjk: true) = {
    if cjk { stretch(3.1em, label) } else {
      box(width: 3.1em, align(left, label))
    }
    h(tex-pt(1))
    meta-ul(value)
    h(tex-pt(3))
  }
  let report-date = date-zh-digits(info.date, day: false)
  let serif-ascent(body) = ink-ascent(text(
    font: config.fonts.SongTi,
    size: body-size,
    body,
  ))

  set text(font: config.fonts.SongTi, lang: "zh", region: "CN")
  set block(spacing: 0pt)
  align(center)[
    #v(tex-pt(12) + meta-base - 0.8 * meta-size + 0.35cm)
    #_postdoc-line(meta-size, grid(
      columns: (1fr, 1fr),
      align: (left, right),
      top-line("分类号", info.at("clc", default: [])),
      [密级#h(tex-pt(1))#meta-ul(info.at("secret-level", default: []))],
    ))
    #v(meta-base - meta-size)
    #_postdoc-line(meta-size, grid(
      columns: (1fr, 1fr),
      align: (left, right),
      top-line("U D C", info.at("udc", default: []), cjk: false),
      [编号#h(tex-pt(1))#meta-ul(info.at("id", default: []))],
    ))
    #v(3.15cm + head-base - 0.2 * meta-size - 0.8 * head-size)
    #_postdoc-line(head-size, text(
      font: config.fonts.HeiTi,
      weight: "bold",
      tracking: 1.5em,
      [清华大学],
    ))
    #v(head-base - head-size)
    #_postdoc-line(head-size, text(
      font: config.fonts.HeiTi,
      weight: "bold",
      tracking: 0.5em,
      [博士后研究工作报告],
    ))
    #v(0.2cm + bp(20) - 0.2 * head-size)
    #block(
      width: 100%,
      height: 4cm,
      align(center + horizon, pad(
        bottom: 0.8 * title-size,
        line-height(title-size, title-base, underline(
          offset: 1em,
          stroke: tex-pt(0.7),
          info.title,
        )),
      )),
    )
    #context v(0.4cm + tex-pt(1) + serif-ascent(info.author) - 0.8 * body-size)
    #_postdoc-line(body-size, info.author)
    #v(1.4cm + date-base - body-size)
    #_postdoc-line(body-size)[
      工作完成日期#h(1em)#date-ul([#date-zh-digits(
          info.start-date,
          day: false,
        )—#date-zh-digits(info.end-date, day: false)])
    ]
    #context v(
      0.55cm
        + tex-pt(1)
        + serif-ascent([报告提交日期#h(1em)#report-date])
        - 0.1 * body-size,
    )
    #_postdoc-line(body-size)[报告提交日期#h(1em)#date-ul(report-date)]
    #v(0.45cm + inst-base - body-size)
    #_postdoc-line(body-size)[#text(tracking: 1em, [清华大学])#h(
        1em,
      )#text[（北京）]]
    #v(0.25cm + inst-base - body-size)
    #_postdoc-line(body-size, report-date)
  ]
})

#let postdoc-title-page(config) = cover-page(3cm, {
  let info = config.info
  let body-size = bp(12)
  let body-base = body-size * 2.6
  let final-size = bp(10.5)
  let final-base = final-size * 1.3
  let centered-parbox(size, baseline, body) = block(
    width: 100%,
    height: 3cm,
    align(center + horizon, line-height(size, baseline, body)),
  )
  let cell(body) = array-cell(
    body-size,
    body-base,
    box(height: body-size, text(
      size: body-size,
      top-edge: 0.8em,
      bottom-edge: -0.2em,
      body,
    )),
  )
  let start-row = [研究工作起始时间#h(1em)#date-zh-digits(info.start-date)]

  set text(font: config.fonts.SongTi, lang: "zh", region: "CN")
  set block(spacing: 0pt)
  align(center)[
    #v(tex-pt(12) + bp(20) + 1.5cm)
    #centered-parbox(bp(16), bp(16) * 1.95, info.title)
    #v(0.15cm + tex-pt(1))
    #centered-parbox(bp(14), bp(14) * 1.36, info.title-en)
    #v(0.4cm + tex-pt(1))
    #block(width: 100%, align(center, pad(
      x: tex-pt(6),
      grid(
        columns: (11 * body-size, body-size, auto),
        align: left,
        cell(distribute(11 * body-size, "博士后姓名")), [], cell(info.author),
        cell(distribute(11 * body-size, "流动站（一级学科）名称")),
        [],
        cell(info.discipline-level-1),
        cell(distribute(11 * body-size, (
          "专",
          h(body-size),
          "业（二级学科）名称",
        ))),
        [],
        cell(info.discipline-level-2),
      ),
    )))
    #context v(
      2.7cm
        + tex-pt(1)
        + ink-ascent(text(
          font: config.fonts.SongTi,
          size: body-size,
          start-row,
        ))
        - 0.8 * body-size,
    )
    #_postdoc-line(body-size, start-row)
    #v(0.1cm + body-base - body-size)
    #_postdoc-line(body-size)[研究工作期满时间#h(1em)#date-zh-digits(
        info.end-date,
      )]
    #v(2.1cm + body-base - body-size)
    #_postdoc-line(body-size, [清华大学人事处（北京）])
    #v(0.6cm + final-base - 0.2 * body-size - 0.8 * final-size)
    #_postdoc-line(final-size, date-zh-digits(info.date, day: false))
  ]
})

#import "../config.typ": sans-fonts, serif-fonts
#import "../layouts/pagebreak.typ": clear-page
#import "../utils/dates.typ": date-zh-digits
#import "../utils/text.typ": bp, distribute, line-height, stretch, tex-pt, tex-vlist-boundary

// A TeX line is a baseline-oriented hbox.  Keeping that hbox separate from
// Typst's paragraph frame prevents a one-line paragraph from consuming a
// full requested baseline below its ink.
//
// The 0.8em/0.2em split is not a LaTeX layout constant: it is the local
// Typst frame convention defined by `line-height` in utils/text.typ. These
// names only convert between that frame edge and TeX's baseline/depth model.
#let _postdoc-frame-ascent = 0.8

#let _postdoc-frame-descent = 0.2

// LaTeX sources: size12.clo sets `\topskip=12pt`; latex.ltx sets
// `\normallineskip=1pt`; thuthesis.dtx:2223 sets `\normalsize` to 12/20bp.
#let _postdoc-topskip = tex-pt(12)

#let _postdoc-lineskip = tex-pt(1)

#let _postdoc-surrounding-baseline = bp(20)

#let _postdoc-line(size, body, alignment: center) = block(
  width: 100%,
  height: size,
  clip: false,
  align(alignment, text(
    size: size,
    top-edge: 0.8em,
    bottom-edge: -0.2em,
    body,
  )),
)

#let _postdoc-cover(config) = {
  let info = config.info
  let date = info.date
  let start = info.start-date
  let end = info.end-date
  // thuthesis.dtx:5006,5013,5019,5024,5026,5038,5040.  The optional
  // arguments of `\sihao`, `\xiaoer`, and `\xiaosi` multiply the font size
  // to produce the requested baseline; none of these are fitted offsets.
  let metadata-size = bp(14)
  let metadata-baseline = metadata-size * 2.6
  let heading-size = bp(18)
  let heading-baseline = heading-size * 2.6
  let title-size = bp(14)
  let title-baseline = title-size * 3.46
  let body-size = bp(12)
  let date-baseline = body-size * 1.58
  let institution-baseline = body-size * 2
  let metadata-underline(value) = {
    // TeX's primitive `\underline` uses XITS Math's OpenType MATH
    // constants: 0.198em vertical gap and 0.066em rule thickness.  The
    // surrounding `\ULthickness` assignment only affects ulem, not this
    // primitive underline (thuthesis.dtx:5004,5007-5010).
    let gap = 0.198 * metadata-size
    let thickness = 0.066 * metadata-size
    box(
      width: 3.7cm,
      height: metadata-size,
      baseline: _postdoc-frame-ascent * metadata-size,
      clip: false,
      {
        place(
          top + left,
          dy: gap + thickness / 2,
          line(length: 100%, stroke: thickness),
        )
        move(
          dy: -_postdoc-frame-ascent * metadata-size,
          block(width: 100%, align(top + center, value)),
        )
      },
    )
  }
  let date-underline(body) = box(
    width: 5.9cm,
    height: body-size,
    baseline: _postdoc-frame-ascent * body-size,
    clip: false,
    {
      // thuthesis.dtx:5027 sets `\ULdepth=0.9em`; unlike a padded box,
      // ulem's rule does not change the line's reference baseline.
      place(
        top + left,
        dy: 0.9 * body-size,
        line(length: 100%, stroke: tex-pt(0.7)),
      )
      move(
        dy: -_postdoc-frame-ascent * body-size,
        block(width: 100%, align(top + center, body)),
      )
    },
  )
  let top-line(label, value, cjk: true) = {
    if cjk {
      stretch(3.1em, label)
    } else {
      // `\thu@stretch` only stretches XeCJK's `\CJKglue`.  Latin spaces
      // in “U D C” therefore keep their natural width and the 3.1em box is
      // padded on the right; distributing Latin clusters is not equivalent.
      box(width: 3.1em, align(left, label))
    }
    h(tex-pt(1))
    metadata-underline(value)
    h(tex-pt(3))
  }
  let report-date-value = date-zh-digits(date, day: false)
  let report-date-row = [报告提交日期#h(1em)#date-underline(report-date-value)]
  set page(
    paper: "a4",
    margin: 3cm,
    header: none,
    footer: none,
    numbering: none,
  )
  set text(font: serif-fonts(config), lang: "zh", region: "CN")
  set block(spacing: 0pt)
  align(center)[
    // `center` starts with an empty line at `topskip`; the first 14bp line
    // is then appended at its requested 36.4bp baseline.
    #v(
      _postdoc-topskip
        + metadata-baseline
        - _postdoc-frame-ascent * metadata-size
        + 0.35cm,
    )
    #_postdoc-line(metadata-size, grid(
      columns: (1fr, 1fr),
      align: (left, right),
      top-line("分类号", info.at("clc", default: [])),
      {
        [密级]
        h(tex-pt(1))
        metadata-underline(info.at("secret-level", default: []))
      },
    ))
    #v(metadata-baseline - metadata-size)
    #_postdoc-line(metadata-size, grid(
      columns: (1fr, 1fr),
      align: (left, right),
      top-line("U D C", info.at("udc", default: []), cjk: false),
      {
        [编号]
        h(tex-pt(1))
        metadata-underline(info.at("id", default: []))
      },
    ))
    // An explicit vskip between TeX paragraphs is followed by the next
    // baseline glue.  Convert that baseline to the two line-frame edges.
    #v(
      3.15cm
        + heading-baseline
        - _postdoc-frame-descent * metadata-size
        - _postdoc-frame-ascent * heading-size,
    )
    #_postdoc-line(heading-size, text(
      font: sans-fonts(config),
      weight: "bold",
      tracking: 1.5em,
      [清华大学],
    ))
    #v(heading-baseline - heading-size)
    #_postdoc-line(heading-size, text(
      font: sans-fonts(config),
      weight: "bold",
      tracking: 0.5em,
      [博士后研究工作报告],
    ))
    // A top-aligned parbox has zero height at its reference baseline and
    // follows the surrounding 20bp paragraph baseline.
    #v(
      0.2cm
        + _postdoc-surrounding-baseline
        - _postdoc-frame-descent * heading-size,
    )
    #block(
      width: 100%,
      height: 4cm,
      align(center + horizon, pad(
        // `line-height` already reserves 0.2em below the baseline.  ulem's
        // `\ULdepth=1em` in thuthesis.dtx:5020 adds the remaining 0.8em to
        // the title paragraph's last line before `parbox[c]` centres it.
        bottom: (1 - _postdoc-frame-descent) * title-size,
        line-height(title-size, title-baseline, underline(
          offset: 1em,
          stroke: tex-pt(0.7),
          info.title,
        )),
      )),
    )
    // The deep parbox and both underlined date rows trigger TeX's 1pt
    // `lineskip` branch instead of its normal baseline glue.
    #context {
      let author-height = measure(text(
        font: serif-fonts(config),
        size: body-size,
        top-edge: "bounds",
        bottom-edge: "baseline",
        info.author,
      )).height
      v(
        tex-vlist-boundary(
          _postdoc-surrounding-baseline,
          4cm,
          author-height,
          skip: 0.4cm,
          previous-frame-depth: 4cm,
          next-frame-height: _postdoc-frame-ascent * body-size,
          mode: "lineskip",
        ).spacing,
      )
    }
    #_postdoc-line(body-size, info.author)
    #v(1.4cm + date-baseline - body-size)
    #_postdoc-line(body-size)[
      工作完成日期#h(1em)#date-underline([#date-zh-digits(start, day: false)—#date-zh-digits(
          end,
          day: false,
        )])
    ]
    #context {
      v(
        tex-vlist-boundary(
          date-baseline,
          0.9 * body-size,
          measure(text(
            font: serif-fonts(config),
            size: body-size,
            top-edge: "bounds",
            bottom-edge: "baseline",
            [报告提交日期#h(1em)#report-date-value],
          )).height,
          skip: 0.55cm,
          previous-frame-depth: _postdoc-frame-descent * body-size,
          next-frame-height: _postdoc-frame-ascent * body-size,
          mode: "lineskip",
        ).spacing,
      )
    }
    #_postdoc-line(body-size, report-date-row)
    #v(0.45cm + institution-baseline - body-size)
    #_postdoc-line(body-size)[
      #text(tracking: 1em, [清华大学])#h(1em)#text[（北京）]
    ]
    #v(0.25cm + institution-baseline - body-size)
    #_postdoc-line(body-size, date-zh-digits(date, day: false))
  ]
  clear-page()
}

#let _postdoc-title-page(config) = {
  let info = config.info
  let date = info.date
  let start = info.start-date
  let end = info.end-date
  // thuthesis.dtx:5052,5056,5059,5068,5074,5076.  In particular, the
  // repeated 31.2bp is derived as both 16bp*1.95 and 12bp*2.6.
  let chinese-title-size = bp(16)
  let chinese-title-baseline = chinese-title-size * 1.95
  let english-title-size = bp(14)
  let english-title-baseline = english-title-size * 1.36
  let body-size = bp(12)
  let body-baseline = body-size * 2.6
  let final-date-size = bp(10.5)
  let final-date-baseline = final-date-size * 1.3
  let centered-parbox(height, size, baseline, body) = block(
    width: 100%,
    height: height,
    // thuthesis.dtx:5051-5057 uses `parbox[t][3cm][c]`: retain the fixed
    // outer height, vertical centring and the named font's baseline.
    align(center + horizon, line-height(size, baseline, body)),
  )
  let table-baseline = body-baseline
  let table-line(body) = box(
    height: body-size,
    clip: false,
    text(
      size: body-size,
      top-edge: 0.8em,
      bottom-edge: -0.2em,
      body,
    ),
  )
  let table-cell(body) = pad(
    // latex.ltx's `\strutbox` is 0.7 baseline high and 0.3 deep;
    // thuthesis.dtx:5061 keeps `\arraystretch=1` for this table.
    top: 0.7 * table-baseline - _postdoc-frame-ascent * body-size,
    bottom: 0.3 * table-baseline - _postdoc-frame-descent * body-size,
    table-line(body),
  )
  let information-table = block(width: 100%, align(center, pad(
    x: tex-pt(6),
    grid(
      columns: (11 * body-size, body-size, auto),
      column-gutter: 0pt,
      row-gutter: 0pt,
      align: left,
      table-cell(distribute(11 * body-size, "博士后姓名")),
      [],
      table-cell(info.author),

      table-cell(distribute(11 * body-size, "流动站（一级学科）名称")),
      [],
      table-cell(info.discipline-level-1),

      table-cell(distribute(
        11 * body-size,
        ("专", h(body-size), "业（二级学科）名称"),
      )),
      [],
      table-cell(info.discipline-level-2),
    ),
  )))
  let start-date-row = [研究工作起始时间#h(1em)#date-zh-digits(start)]
  set page(
    paper: "a4",
    margin: 3cm,
    header: none,
    footer: none,
    numbering: none,
  )
  set text(font: serif-fonts(config), lang: "zh", region: "CN")
  set block(spacing: 0pt)
  align(center)[
    // The first top-aligned parbox follows the empty `center` line at the
    // class's 20bp body baseline.
    #v(_postdoc-topskip + _postdoc-surrounding-baseline + 1.5cm)
    #centered-parbox(
      3cm,
      chinese-title-size,
      chinese-title-baseline,
      info.title,
    )
    #v(0.15cm + _postdoc-lineskip)
    #centered-parbox(
      3cm,
      english-title-size,
      english-title-baseline,
      info.title-en,
    )
    #v(0.4cm + _postdoc-lineskip)
    #information-table
    #context {
      v(
        tex-vlist-boundary(
          body-baseline,
          0pt,
          measure(text(
            font: serif-fonts(config),
            size: body-size,
            top-edge: "bounds",
            bottom-edge: "baseline",
            start-date-row,
          )).height,
          skip: 2.7cm,
          previous-frame-depth: 0pt,
          next-frame-height: _postdoc-frame-ascent * body-size,
          mode: "lineskip",
        ).spacing,
      )
    }
    #_postdoc-line(body-size, start-date-row)
    #v(0.1cm + body-baseline - body-size)
    #_postdoc-line(body-size)[
      研究工作期满时间#h(1em)#date-zh-digits(end)
    ]
    #v(2.1cm + body-baseline - body-size)
    #_postdoc-line(body-size, [清华大学人事处（北京）])
    #v(
      0.6cm
        + final-date-baseline
        - _postdoc-frame-descent * body-size
        - _postdoc-frame-ascent * final-date-size,
    )
    #_postdoc-line(final-date-size, date-zh-digits(date, day: false))
  ]
  clear-page()
}

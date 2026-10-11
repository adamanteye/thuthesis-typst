#import "../config.typ": chinese, fangsong-fonts, sans-fonts, serif-fonts
#import "../layouts/pagebreak.typ": clear-page
#import "cover-info.typ": _graduate-info
#import "../utils/dates.typ": date-zh
#import "../utils/text.typ": bp, content-ink-ascent, line-height, tex-pt, tex-vlist-boundary

#let _degree-label(config) = {
  let category = config.info.degree-category
  // \CJKfamily+ selects the CJK serif face for Latin glyphs as well.
  // XeTeX inserts its 1bp glue only between adjacent Chinese characters.
  let fonts = serif-fonts(config)
  set text(font: fonts.slice(1) + (fonts.first(),))
  show regex("\\p{Han}+"): set text(tracking: bp(1))
  text("(")
  if config.thesis-type == "proposal" {
    [清华大学]
    if config.degree == "doctor" { [博士] } else { [硕士] }
    [学位论文选题报告]
  } else {
    [申请清华大学]
    category
    if config.degree-type == "professional" { [专业] }
    [学位论文]
  }
  text(")")
}

#let _graduate-cover(config) = {
  let info = config.info
  let date = info.date
  let normal-baseline = bp(20)
  let secret-size = bp(16)
  let secret = if info.at("secret-level", default: none) != none {
    [#info.at("secret-level")★#box(width: 3em, align(center, str(info.at(
        "secret-year",
        default: "",
      ))))年]
  } else {
    // thuthesis.dtx:4650 uses the same text in `\phantom`.
    hide([秘密])
  }
  // thuthesis.dtx:4598,4604 writes these `\fontsize` pairs literally;
  // unlike named-size commands, their baselines are not derived defaults.
  let title-size = bp(26)
  let title-baseline = bp(46.8)
  let english-title-size = bp(20)
  let english-title-baseline = bp(31.2)
  let degree-size = bp(16)
  let degree-baseline = bp(22)
  // Fixed heights from the two `\parbox[t][...][t]` declarations in
  // `\thu@titlepage@thesis`.
  let secret-box-height = 2cm
  let date-box-height = 1.03cm
  let paragraph-baseline-skip(
    skip,
    from-descent,
    to-size,
    to-baseline,
    frame-leading: true,
  ) = (
    skip
      + to-baseline
      - from-descent
      - if frame-leading { to-baseline - to-size } else { 0pt }
      - 0.8 * to-size
  )
  set page(
    paper: "a4",
    margin: (top: 2cm, bottom: 6cm, left: 3.5cm, right: 3.5cm),
    header: none,
    footer: none,
    numbering: none,
  )
  set text(font: serif-fonts(config), size: bp(12), lang: "zh", region: "CN")
  align(center)[
    // At the top of a TeX page, `\null` establishes the first baseline at
    // `\topskip`.  The following 2cm top-aligned parbox is still carried by
    // a normal 20bp line, so TeX inserts the remaining baseline glue before
    // the parbox and falls back to `\lineskip` before the 26bp title line.
    #v(tex-pt(12))
    #v(tex-pt(8.1))
    #context {
      v(
        normal-baseline
          - content-ink-ascent(text(
            font: sans-fonts(config),
            size: secret-size,
            secret,
          )),
      )
    }
    #block(
      height: secret-box-height,
      width: 100%,
      above: 0pt,
      below: 0pt,
      align(top + left)[
        #move(dx: -tex-pt(21.5), text(
          font: sans-fonts(config),
          size: secret-size,
          secret,
        ))
      ],
    )
    #v(tex-pt(40.5))
    #context {
      let title-ascent = content-ink-ascent(text(
        font: sans-fonts(config),
        size: title-size,
        info.title,
      ))
      // Keep Typst's one-em line frame while deriving where its baseline
      // splits that frame from the selected font and the actual title.
      let title-descent = title-size - title-ascent
      [
        #v(
          tex-vlist-boundary(
            normal-baseline,
            secret-box-height,
            title-ascent,
          ).spacing,
        )
        #line-height(
          title-size,
          title-baseline,
          text(
            font: sans-fonts(config),
            top-edge: title-ascent,
            bottom-edge: -title-descent,
            info.title,
          ),
          paragraph-spacing: 0pt,
        )
        #if not chinese(config) {
          v(paragraph-baseline-skip(
            tex-pt(5.4),
            title-descent,
            english-title-size,
            english-title-baseline,
            frame-leading: false,
          ))
          line-height(
            english-title-size,
            english-title-baseline,
            text(
              font: sans-fonts(config),
              weight: "bold",
              info.at("title-en"),
            ),
            paragraph-spacing: 0pt,
          )
        }
        // TeX changes to the degree line's 22bp baseline after the explicit
        // skip. Remove the adjoining paragraph edges and leading that Typst
        // would otherwise add around that same baseline-to-baseline distance.
        #let previous-descent = if chinese(config) {
          title-descent
        } else {
          0.2 * english-title-size
        }
        #let degree-skip = if chinese(config) {
          tex-pt(24.1)
        } else {
          tex-pt(24.1 - 9.2)
        }
        #v(paragraph-baseline-skip(
          degree-skip,
          previous-descent,
          degree-size,
          degree-baseline,
        ))
        #line-height(
          degree-size,
          degree-baseline,
          _degree-label(config),
        )
      ]
    }
    #v(1fr)
    #block(
      width: 100%,
      height: if config.degree-type == "academic" { 7.25cm } else { 5.25cm },
      above: 0pt,
      below: 0pt,
      align(
        if config.degree-type == "academic" { top + left } else {
          bottom + left
        },
        text(
          font: fangsong-fonts(config),
          size: bp(16),
          top-edge: 0.8em,
          bottom-edge: -0.2em,
          _graduate-info(config),
        ),
      ),
    )
    #if config.degree-type == "professional" { v(tex-pt(62)) }
    // Both LaTeX parboxes occupy ordinary lines.  Since their combined
    // height and depth exceed the body baseline, TeX separates the lines by
    // `\lineskip`; the title-page macro then lets the date overhang the text
    // area by cancelling 6pt after that line.
    #v(tex-vlist-boundary(normal-baseline, 0pt, date-box-height).spacing)
    #block(
      width: 100%,
      height: date-box-height,
      above: 0pt,
      below: 0pt,
      align(top + center, text(
        size: bp(16),
        tracking: bp(1),
        top-edge: "bounds",
        date-zh(date),
      )),
    )
    #v(-tex-pt(6))
  ]
  clear-page()
}

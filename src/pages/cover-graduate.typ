#import "../config.typ": chinese
#import "common.typ": cover-page
#import "cover-info.typ": graduate-info
#import "../utils/dates.typ": date-zh
#import "../utils/text.typ": bp, ink-ascent, line-height, tex-pt

#let _degree-label(config) = {
  let fonts = config.fonts.SongTi
  set text(font: fonts.slice(1) + (fonts.first(),))
  show regex("\\p{Han}+"): set text(tracking: bp(1))
  text("(")
  if config.thesis-type == "proposal" {
    [清华大学#if config.degree == "doctor" [博士] else [硕士]学位论文选题报告]
  } else {
    [申请清华大学#config.info.degree-category#if (
        config.degree-type == "professional"
      ) [专业]学位论文]
  }
  text(")")
}

#let graduate-cover(config) = cover-page((top: 2cm, bottom: 6cm, x: 3.5cm), {
  let info = config.info
  let secret-size = bp(16)
  let secret = if info.at("secret-level", default: none) != none {
    [#info.at("secret-level")★#box(width: 3em, align(center, str(info.at(
        "secret-year",
        default: "",
      ))))年]
  } else {
    hide([秘密])
  }
  let title-size = bp(26)
  let title-baseline = bp(46.8)
  let en-size = bp(20)
  let en-baseline = bp(31.2)
  let degree-size = bp(16)
  let degree-baseline = bp(22)
  set text(font: config.fonts.SongTi, size: bp(12), lang: "zh", region: "CN")
  align(center)[
    #v(tex-pt(12))
    #v(tex-pt(8.1))
    #context v(
      bp(20)
        - ink-ascent(text(font: config.fonts.HeiTi, size: secret-size, secret)),
    )
    #block(
      height: 2cm,
      width: 100%,
      above: 0pt,
      below: 0pt,
      align(top + left, move(dx: -tex-pt(21.5), text(
        font: config.fonts.HeiTi,
        size: secret-size,
        secret,
      ))),
    )
    #v(tex-pt(40.5))
    #context {
      let title-ascent = ink-ascent(text(
        font: config.fonts.HeiTi,
        size: title-size,
        info.title,
      ))
      let title-descent = title-size - title-ascent
      v(tex-pt(1))
      line-height(
        title-size,
        title-baseline,
        text(
          font: config.fonts.HeiTi,
          top-edge: title-ascent,
          bottom-edge: -title-descent,
          info.title,
        ),
        paragraph-spacing: 0pt,
      )
      if not chinese(config) {
        v(tex-pt(5.4) + en-baseline - title-descent - 0.8 * en-size)
        line-height(
          en-size,
          en-baseline,
          text(font: config.fonts.HeiTi, weight: "bold", info.title-en),
          paragraph-spacing: 0pt,
        )
      }
      v(
        (if chinese(config) { tex-pt(24.1) } else { tex-pt(24.1 - 9.2) })
          + 0.2 * degree-size
          - (if chinese(config) { title-descent } else { 0.2 * en-size }),
      )
      line-height(degree-size, degree-baseline, _degree-label(config))
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
          font: config.fonts.FangSong,
          size: bp(16),
          top-edge: 0.8em,
          bottom-edge: -0.2em,
          graduate-info(config),
        ),
      ),
    )
    #if config.degree-type == "professional" { v(tex-pt(62)) }
    #v(tex-pt(1))
    #block(
      width: 100%,
      height: 1.03cm,
      above: 0pt,
      below: 0pt,
      align(top + center, text(
        size: bp(16),
        tracking: bp(1),
        top-edge: "bounds",
        date-zh(info.date),
      )),
    )
    #v(-tex-pt(6))
  ]
})

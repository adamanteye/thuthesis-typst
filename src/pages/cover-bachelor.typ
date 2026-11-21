#import "../config.typ": chinese
#import "common.typ": cover-page
#import "cover-info.typ": bachelor-info
#import "../utils/dates.typ": date-zh
#import "../utils/text.typ": bp, ink-ascent, ink-descent, line-height, tex-pt

#let bachelor-cover(config) = cover-page(
  (top: 3.8cm, bottom: 3.2cm, left: 3.2cm, right: 3cm),
  {
    let info = config.info
    let heading-size = bp(36)
    let heading-baseline = heading-size * 1.3
    let title-size = bp(26)
    let title-baseline = bp(32.5)
    let logo-size = bp(49)
    let title-box-height = bp(136)
    let latin-serif = config.fonts.SongTi.first()
    let latin-name = if type(latin-serif) == str { latin-serif } else {
      latin-serif.name
    }
    set text(font: config.fonts.SongTi, lang: "zh", region: "CN")
    box(width: 100%, height: 0pt, align(top + right, text(size: bp(12))[
      #if info.at("secret-level", default: none) != none {
        [#info.at("secret-level")#text(" ")#str(info.at(
            "secret-year",
            default: "",
          ))#text(" ")年]
      }
    ]))
    v(bp(21))
    align(center)[
      #v(tex-pt(12) + tex-pt(1))
      #block(
        width: 100%,
        height: logo-size,
        above: 0pt,
        below: 0pt,
        align(bottom + center, grid(
          columns: (bp(49), bp(10), bp(112)),
          align: bottom + center,
          image("../../assets/thu-fig-logo.pdf", width: logo-size),
          [],
          move(
            dy: -bp(4.5),
            image(
              "../../assets/thu-text-logo.pdf",
              width: bp(112),
              height: bp(41),
              fit: "stretch",
            ),
          ),
        )),
      )
      #v(bp(21.5))
      #context {
        let heading-style(body) = text(
          font: config.fonts.HeiTi,
          weight: "bold",
          size: heading-size,
          tracking: 0.3em,
          body,
        )
        let heading-lines = (
          [综合论文训练],
          ..if config.thesis-type == "proposal" { ([开题报告],) } else { () },
        )
        stack(spacing: 0pt, ..heading-lines.map(line => block(
          width: 100%,
          height: heading-baseline,
          above: 0pt,
          below: 0pt,
          align(bottom + center, text(
            top-edge: "bounds",
            bottom-edge: "baseline",
            heading-style(line),
          )),
        )))
        v(ink-descent(heading-style(heading-lines.last())) + bp(48) + tex-pt(1))
        block(
          width: 100%,
          height: title-box-height,
          above: 0pt,
          below: 0pt,
          align(top + center, {
            // `\heiti` switches only the CJK family in the bachelor title.
            let title = text(
              font: (
                (name: latin-name, covers: regex("\\P{scx:Han}")),
                ..config.fonts.HeiTi,
              ),
              info.title,
            )
            if chinese(config) {
              line-height(
                title-size,
                title-baseline,
                text(top-edge: "bounds", bottom-edge: "bounds", title),
                paragraph-spacing: 0pt,
              )
            } else {
              let ascent = ink-ascent(text(size: title-size, title))
              line-height(title-size, title-baseline, {
                set text(top-edge: ascent, bottom-edge: ascent - title-size)
                title
                linebreak()
                text(font: config.fonts.SongTi, lang: "en", info.title-en)
              })
            }
          }),
        )
      }
      #v(tex-pt(1))
      #bachelor-info(config)
      #v(1fr)
      #line-height(bp(16), bp(24), text(
        tracking: 0.03em,
        bottom-edge: "bounds",
        date-zh(info.date),
      ))
      #v(bp(53))
    ]
  },
)

#import "../config.typ": chinese, sans-fonts, serif-fonts
#import "../layouts/pagebreak.typ": clear-page
#import "cover-info.typ": _bachelor-info
#import "../utils/dates.typ": date-zh
#import "../utils/font.typ": _unwrap-font
#import "../utils/text.typ": bp, content-ink-ascent, line-height, tex-pt, tex-vlist-boundary

#let _bachelor-cover(config) = {
  let info = config.info
  let date = info.date
  let heading-size = bp(36)
  let heading-baseline = heading-size * 1.3
  let title-size = bp(26)
  // thuthesis.dtx:4933 explicitly writes `\fontsize{26bp}{32.5bp}`.
  let title-baseline = bp(32.5)
  // The source logo is square and included at 49bp; the title is the
  // `\parbox[t][136bp]` immediately below it.
  let logo-size = bp(49)
  let title-box-height = bp(136)
  set page(
    paper: "a4",
    margin: (top: 3.8cm, bottom: 3.2cm, left: 3.2cm, right: 3cm),
    header: none,
    footer: none,
    numbering: none,
  )
  set text(font: serif-fonts(config), lang: "zh", region: "CN")
  box(width: 100%, height: 0pt, align(top + right, text(size: bp(12))[
    #if info.at("secret-level", default: none) != none {
      info.at("secret-level")
      text(" ")
      str(info.at("secret-year", default: ""))
      text(" ")
      [年]
    }
  ]))
  v(bp(21))
  align(center)[
    // The zero-height secrecy parbox still establishes TeX's 12pt top-skip.
    // The following 49bp image line is too tall for the normal baseline, so
    // TeX adds its 1pt lineskip before the line box.
    #v(tex-pt(12) + tex-vlist-boundary(bp(20), 0pt, logo-size).spacing)
    #block(
      width: 100%,
      height: logo-size,
      above: 0pt,
      below: 0pt,
      align(bottom + center, grid(
        columns: (bp(49), bp(10), bp(112)),
        // The two graphics are inline boxes in LaTeX: their bottoms share a
        // baseline before the wordmark is raised by 4.5bp.
        align: (bottom + center, bottom + center, bottom + center),
        image("../../assets/thu-fig-logo.pdf", width: logo-size),
        [],
        move(
          dy: -bp(4.5),
          image(
            "../../assets/thu-text-logo.pdf",
            width: bp(112),
            height: bp(41),
            // LaTeX's `\includegraphics[width=112bp, height=41bp]`
            // scales the 143pt × 47pt source independently on both axes.
            fit: "stretch",
          ),
        ),
      )),
    )
    #v(bp(21.5))
    // These are ordinary TeX paragraph lines: the first heading baseline is
    // a full 1.3-line baseline below the preceding image baseline. Typst's
    // default first-line frame includes only half-leading, so use explicit
    // baseline-high blocks whose bottoms are the baselines.
    #context {
      let heading-line(body) = block(
        width: 100%,
        height: heading-baseline,
        above: 0pt,
        below: 0pt,
        align(bottom + center, text(
          font: sans-fonts(config),
          weight: "bold",
          size: heading-size,
          tracking: 0.3em,
          top-edge: "bounds",
          bottom-edge: "baseline",
          body,
        )),
      )
      let heading-lines = (
        [综合论文训练],
        ..if config.thesis-type == "proposal" { ([开题报告],) } else { () },
      )
      stack(spacing: 0pt, ..heading-lines.map(heading-line))

      let last-heading = heading-lines.last()
      let heading-depth = measure(text(
        font: sans-fonts(config),
        weight: "bold",
        size: heading-size,
        tracking: 0.3em,
        top-edge: 0em,
        bottom-edge: "bounds",
        last-heading,
      )).height

      // The title is the first line of a 136bp top-aligned parbox. TeX
      // reaches its top through the preceding glyph depth, 48bp source skip
      // and the 1pt lineskip used between the two oversized line boxes.
      v(
        heading-depth
          + bp(48)
          + tex-vlist-boundary(bp(20), 0pt, title-box-height).spacing,
      )
      block(
        width: 100%,
        height: title-box-height,
        above: 0pt,
        below: 0pt,
        align(top + center, {
          // \heiti changes only the CJK family in the bachelor title.
          let title = text(
            font: (
              (name: _unwrap-font(serif-fonts(config).first()), covers: regex("\\P{scx:Han}")),
              ..sans-fonts(config),
            ),
            info.title,
          )
          if chinese(config) {
            line-height(title-size, title-baseline, text(
              top-edge: "bounds",
              bottom-edge: "bounds",
              title,
            ), paragraph-spacing: 0pt)
          } else {
            // Both titles share TeX's 32.5bp baseline grid. Anchor the
            // first line at the Chinese ink ascent and let both wrap.
            let ascent = content-ink-ascent(text(size: title-size, title))
            line-height(title-size, title-baseline, {
              set text(top-edge: ascent, bottom-edge: ascent - title-size)
              title
              linebreak()
              text(font: serif-fonts(config), lang: "en", info.title-en)
            })
          }
        }),
      )
    }
    // The information tabular is another oversized line box, so TeX puts
    // its 1pt lineskip immediately after the fixed-height title parbox.
    #v(tex-vlist-boundary(bp(20), title-box-height, 0pt).spacing)
    #_bachelor-info(config)
    #v(1fr)
    #line-height(
      bp(16),
      bp(24),
      // TeX inserts the final 53bp below the date's actual glyph depth.
      text(tracking: 0.03em, bottom-edge: "bounds", date-zh(date)),
    )
    #v(bp(53))
  ]
  clear-page()
}

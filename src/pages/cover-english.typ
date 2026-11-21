#import "common.typ": cover-page
#import "../utils/dates.typ": date-en
#import "../utils/people.typ": english-person
#import "../utils/text.typ": (
  array-cell, bp, ink-ascent, ink-descent, line-height, tex-glue, tex-pt,
)

#let _english-degree(config, thesis-name) = {
  let size = bp(16)
  let baseline = size * 1.725
  let line(body, font: config.fonts.SongTi, weight: "regular") = block(
    width: 100%,
    height: baseline,
    above: 0pt,
    below: 0pt,
    align(top + center, text(
      font: font,
      weight: weight,
      size: size,
      top-edge: 0.8em,
      bottom-edge: -0.2em,
      body,
    )),
  )
  stack(
    spacing: 0pt,
    line([#thesis-name submitted to]),
    line([Tsinghua University], weight: "bold"),
    line([in partial fulfillment of the requirement]),
    line([for the#text(" ")#if (
        config.degree-type == "professional"
      ) [professional#text(" ")]degree of]),
    line(
      config.info.degree-category-en,
      font: config.fonts.HeiTi,
      weight: "bold",
    ),
    if config.degree-type == "academic" {
      stack(
        spacing: 0pt,
        v(bp(3)),
        line([in]),
        v(bp(3.5)),
        line(
          config.info.discipline-en,
          font: config.fonts.HeiTi,
          weight: "bold",
        ),
      )
    },
  )
}

#let english-title-page(config) = cover-page(
  (top: 5.5cm, bottom: 5cm, x: 3.4cm),
  {
    let info = config.info
    let academic = config.degree-type == "academic"
    let thesis-name = if config.degree == "master" { "Thesis" } else {
      "Dissertation"
    }
    let title-size = bp(20)
    let title-baseline = bp(31.2)
    let surrounding-baseline = bp(16) * 1.725
    let sup-size = bp(15)
    let sup-baseline = sup-size * if academic { 2.1 } else { 1.82 }
    let sup-rows = (
      ([#thesis-name Supervisor], info.supervisor-en),
      (
        [Associate Supervisor],
        info.at("associate-supervisor-en", default: none),
      ),
      ([Co-supervisor], info.at("co-supervisor-en", default: none)),
    ).filter(((_, p)) => p != none)
    // Centered LaTeX tabular `\vcenter` reference height: half strut height + 0.25em math axis.
    let sup-ref-height = sup-rows.len() * sup-baseline / 2 + sup-size / 4
    let gap(prev-d, next-h, skip) = (
      skip + tex-glue(surrounding-baseline, prev-d, next-h)
    )
    let cell(body) = array-cell(sup-size, sup-baseline, body)

    set text(font: config.fonts.SongTi, lang: "en")
    set block(spacing: 0pt)
    align(center)[
      #v(-0.31cm)
      #block(
        width: 100%,
        height: bp(143),
        align(top + center, move(
          dy: tex-pt(12) + bp(20) - 0.8 * title-size,
          line-height(title-size, title-baseline, text(
            font: config.fonts.HeiTi,
            weight: "bold",
            info.title-en,
          )),
        )),
      )
      #context {
        let title-ascent = ink-ascent(text(
          font: config.fonts.HeiTi,
          weight: "bold",
          size: title-size,
          info.title-en,
        ))
        let degree-ascent = ink-ascent(text(
          font: config.fonts.SongTi,
          size: bp(16),
          [#thesis-name submitted to],
        ))
        v(
          tex-pt(12)
            + bp(20)
            + tex-pt(1)
            - title-ascent
            + degree-ascent
            - 0.8 * bp(16),
        )
        _english-degree(config, thesis-name)
      }
      #v(1fr)
      #{
        set text(
          font: config.fonts.HeiTi,
          size: bp(16),
          top-edge: "bounds",
          bottom-edge: "bounds",
        )
        stack(
          spacing: surrounding-baseline + 0.24cm - 0.8 * bp(16),
          align(center, text(bottom-edge: "baseline", [by])),
          align(center, text(top-edge: 0.8em, weight: "bold", info.author-en)),
        )
      }
      #context {
        let author-d = ink-descent(text(
          font: config.fonts.HeiTi,
          weight: "bold",
          size: bp(16),
          info.author-en,
        ))
        if academic {
          v(gap(author-d, sup-ref-height, 0.18cm))
        } else if info.at("professional-field-en", default: none) != none {
          let field = text(
            font: config.fonts.HeiTi,
            weight: "bold",
            size: bp(16),
            [(#info.at("professional-field-en"))],
          )
          v(gap(author-d, ink-ascent(field), -0.1cm))
          block(width: 100%, align(center, box(text(
            top-edge: "bounds",
            bottom-edge: "bounds",
            field,
          ))))
          v(gap(ink-descent(field), sup-ref-height, 1.1cm))
        } else {
          v(gap(author-d, sup-ref-height, 1.95cm))
        }
      }
      #block(
        width: 100%,
        height: if academic { 3cm } else { 3.37cm },
        align(top + center, line-height(sup-size, sup-baseline, grid(
          columns: (auto, bp(20.5), auto),
          ..sup-rows
            .map(((label, person)) => (
              cell(align(right, label)),
              cell(align(left, pad(left: bp(2), [:]))),
              cell(align(left, english-person(person))),
            ))
            .flatten(),
        ))),
      )
      #v(tex-pt(1))
      #text(
        font: config.fonts.HeiTi,
        weight: "bold",
        size: bp(16),
        top-edge: "bounds",
        bottom-edge: "bounds",
        date-en(info.date),
      )
      #v(if academic { 0.7cm } else { 0.3cm })
    ]
  },
)

#import "../config.typ": sans-fonts, serif-fonts
#import "../layouts/pagebreak.typ": clear-page
#import "../utils/dates.typ": date-en
#import "../utils/people.typ": english-person
#import "../utils/text.typ": bp, content-ink-ascent, line-height, tex-pt, tex-vlist-boundary

#let _english-supervisors(config, thesis-name, baseline) = {
  let info = config.info
  let size = bp(15)
  let rows = (
    (
      [#thesis-name Supervisor],
      english-person(info.supervisor-en),
    ),
    ..if info.at("associate-supervisor-en", default: none) != none {
      (
        (
          [Associate Supervisor],
          english-person(info.associate-supervisor-en),
        ),
      )
    } else { () },
    ..if info.at("co-supervisor-en", default: none) != none {
      (([Co-supervisor], english-person(info.co-supervisor-en)),)
    } else { () },
  )
  // LaTeX's tabular rows contain an array strut with 70% of the requested
  // baseline above and 30% below. A row gutter preserves the row-to-row
  // distance but leaves the first baseline 0.8em from the parbox top.
  let cell = body => pad(
    top: 0.7 * baseline - 0.8 * size,
    bottom: 0.3 * baseline - 0.2 * size,
    body,
  )
  line-height(size, baseline, grid(
    columns: (auto, bp(20.5), auto),
    column-gutter: 0pt,
    row-gutter: 0pt,
    ..rows
      .map(row => (
        cell(align(right, row.at(0))),
        cell(align(left, pad(left: bp(2), [:]))),
        cell(align(left, row.at(1))),
      ))
      .flatten(),
  ))
}

#let _english-degree(config, thesis-name) = {
  let info = config.info
  let size = bp(16)
  let baseline = size * 1.725
  let line(body, font: serif-fonts(config), weight: "regular") = block(
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
    line({
      [for the]
      text(" ")
      if config.degree-type == "professional" {
        [professional]
        text(" ")
      }
      [degree of]
    }),
    line(
      info.degree-category-en,
      font: sans-fonts(config),
      weight: "bold",
    ),
    if config.degree-type == "academic" {
      stack(
        spacing: 0pt,
        v(bp(3)),
        line([in]),
        v(bp(3.5)),
        line(
          info.discipline-en,
          font: sans-fonts(config),
          weight: "bold",
        ),
      )
    },
  )
}

#let _english-author(config) = {
  let size = bp(16)
  let baseline = size * 1.725
  set text(
    font: sans-fonts(config),
    size: size,
    top-edge: "bounds",
    bottom-edge: "bounds",
  )
  // Measure the gap from the baseline of "by" to the first author baseline.
  // The author's final line keeps its ink depth for the following parbox.
  stack(
    spacing: baseline + 0.24cm - 0.8 * size,
    align(center, text(bottom-edge: "baseline", [by])),
    align(center, text(top-edge: 0.8em, weight: "bold", config.info.author-en)),
  )
}

#let _english-title-page(config) = {
  let info = config.info
  // thuthesis.dtx:4839 explicitly selects `\fontsize{20bp}{31.2bp}`.
  let title-size = bp(20)
  let title-baseline = bp(31.2)
  let surrounding-baseline = bp(16) * 1.725
  let title-box-height = bp(143)
  let supervisor-box-height = if config.degree-type == "academic" {
    3cm
  } else { 3.37cm }
  let supervisor-size = bp(15)
  let supervisor-baseline = (
    supervisor-size
      * if (
        config.degree-type == "academic"
      ) { 2.1 } else { 1.82 }
  )
  let supervisor-rows = (
    1
      + (
        if info.at("associate-supervisor-en", default: none) != none {
          1
        } else {
          0
        }
      )
      + (
        if info.at("co-supervisor-en", default: none) != none { 1 } else { 0 }
      )
  )
  // A centred LaTeX `tabular` is a `\vcenter`: its reference height is
  // half the array's total strut height plus XITS Math's 0.25em axis.
  // `parbox[t]` uses that reference height, not the declared box height.
  let supervisor-reference-height = (
    supervisor-rows * supervisor-baseline / 2 + supervisor-size / 4
  )
  let natural-line(body, weight: "regular") = block(
    width: 100%,
    above: 0pt,
    below: 0pt,
    align(center, box(text(
      font: sans-fonts(config),
      weight: weight,
      size: bp(16),
      top-edge: "bounds",
      bottom-edge: "bounds",
      body,
    ))),
  )
  let author-depth = () => {
    measure(text(
      font: sans-fonts(config),
      weight: "bold",
      size: bp(16),
      top-edge: 0em,
      bottom-edge: "bounds",
      info.author-en,
    )).height
  }
  let thesis-name = if config.degree == "master" { "Thesis" } else {
    "Dissertation"
  }
  let date = info.date
  set page(
    paper: "a4",
    margin: (top: 5.5cm, bottom: 5cm, left: 3.4cm, right: 3.4cm),
    header: none,
    footer: none,
    numbering: none,
  )
  set text(font: serif-fonts(config), lang: "en")
  set block(spacing: 0pt)
  align(center)[
    #v(-0.31cm)
    #block(
      width: 100%,
      height: title-box-height,
      above: 0pt,
      below: 0pt,
      align(top + center, move(
        // `\null` starts an ordinary 20bp line whose first baseline is
        // positioned by the 12pt `\topskip`. Keep the 143bp title region
        // fixed and reproduce that baseline inside it.
        dy: tex-pt(12) + bp(20) - 0.8 * title-size,
        line-height(
          title-size,
          title-baseline,
          text(
            font: sans-fonts(config),
            weight: "bold",
            info.title-en,
          ),
        ),
      )),
    )
    // A TeX top-aligned parbox ends below the first title baseline by its
    // declared height minus the title glyph ascent. The following degree
    // paragraph starts after `lineskip` plus its own glyph ascent. Derive
    // that transition from the two fonts instead of shifting the degree
    // block by an observed coordinate.
    #context {
      let title-ascent = content-ink-ascent(text(
        font: sans-fonts(config),
        weight: "bold",
        size: title-size,
        info.title-en,
      ))
      let degree-ascent = content-ink-ascent(text(
        font: serif-fonts(config),
        size: bp(16),
        [#thesis-name submitted to],
      ))
      v(
        tex-pt(12)
          + bp(20)
          - title-ascent
          + tex-vlist-boundary(
            bp(20),
            title-box-height,
            degree-ascent,
          ).spacing
          + degree-ascent
          - 0.8 * bp(16),
      )
      _english-degree(config, thesis-name)
    }
    #v(1fr)
    // TeX makes `by` and the author two ordinary `\sanhao[1.725]`
    // paragraphs, with the explicit 0.24cm skip added between their
    // baselines. Keep them in one fixed-baseline stack so Typst does not
    // create two extra paragraph frames around the intervening space.
    #_english-author(config)
    #if config.degree-type == "academic" {
      context {
        v(
          tex-vlist-boundary(
            surrounding-baseline,
            author-depth(),
            supervisor-reference-height,
            skip: 0.18cm,
            previous-frame-depth: author-depth(),
            next-frame-height: supervisor-reference-height,
          ).spacing,
        )
      }
    } else if info.at("professional-field-en", default: none) != none {
      let field = [(#info.at("professional-field-en"))]
      context {
        let field-ascent = measure(text(
          font: sans-fonts(config),
          weight: "bold",
          size: bp(16),
          top-edge: "bounds",
          bottom-edge: "baseline",
          field,
        )).height
        v(
          tex-vlist-boundary(
            surrounding-baseline,
            author-depth(),
            field-ascent,
            skip: -0.1cm,
            previous-frame-depth: author-depth(),
            next-frame-height: field-ascent,
          ).spacing,
        )
        natural-line(field, weight: "bold")
        let field-depth = measure(text(
          font: sans-fonts(config),
          weight: "bold",
          size: bp(16),
          top-edge: 0em,
          bottom-edge: "bounds",
          field,
        )).height
        v(
          tex-vlist-boundary(
            surrounding-baseline,
            field-depth,
            supervisor-reference-height,
            skip: 1.1cm,
            previous-frame-depth: field-depth,
            next-frame-height: supervisor-reference-height,
          ).spacing,
        )
      }
    } else {
      context {
        v(
          tex-vlist-boundary(
            surrounding-baseline,
            author-depth(),
            supervisor-reference-height,
            skip: 1.95cm,
            previous-frame-depth: author-depth(),
            next-frame-height: supervisor-reference-height,
          ).spacing,
        )
      }
    }
    #block(
      width: 100%,
      height: supervisor-box-height,
      above: 0pt,
      below: 0pt,
      align(top + center, _english-supervisors(
        config,
        thesis-name,
        supervisor-baseline,
      )),
    )
    #v(
      tex-vlist-boundary(
        surrounding-baseline,
        supervisor-box-height,
        0pt,
      ).spacing,
    )
    #text(
      font: sans-fonts(config),
      weight: "bold",
      size: bp(16),
      top-edge: "bounds",
      bottom-edge: "bounds",
      date-en(date),
    )
    #v(if config.degree-type == "academic" { 0.7cm } else { 0.3cm })
  ]
  clear-page()
}

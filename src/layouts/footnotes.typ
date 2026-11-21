#import "../utils/text.typ": bp, tex-pt

#let _circled-footnotes = "⓪①②③④⑤⑥⑦⑧⑨⑩".clusters()

#let footnote-style(config, body) = {
  let marker-fonts = if (
    config.footnote-style == "circled" and config.fonts.SongTi.len() > 1
  ) {
    config.fonts.SongTi.slice(1)
  } else {
    config.fonts.SongTi
  }
  let size = bp(9)
  let baseline = size * 1.3
  let strut-depth = 0.3 * baseline
  set footnote(numbering: n => if config.footnote-style == "plain"
    or n >= _circled-footnotes.len() {
    str(n)
  } else {
    _circled-footnotes.at(n)
  })
  set footnote.entry(
    separator: block(height: 0pt, place(
      top + left,
      dy: strut-depth - tex-pt(3) + tex-pt(0.4) / 2,
      line(length: 30%, stroke: tex-pt(0.4)),
    )),
    clearance: tex-pt(10.8),
    gap: strut-depth,
    indent: 0pt,
  )
  show footnote.entry: set block(breakable: false)
  show footnote.entry: it => {
    set text(size: size, top-edge: tex-pt(8.4), bottom-edge: "baseline")
    set par(leading: baseline - tex-pt(8.4), spacing: baseline - tex-pt(8.4))
    set list(indent: 0pt, body-indent: 0.5em)
    set enum(indent: 0pt, body-indent: 0.5em)
    let loc = it.note.location()
    grid(
      columns: (bp(13.5), 1fr),
      inset: 0pt,
      text(font: marker-fonts, size: size, link(
        loc,
        counter(footnote).display(it.note.numbering, at: loc),
      )),
      it.note.body,
    )
  }
  body
}

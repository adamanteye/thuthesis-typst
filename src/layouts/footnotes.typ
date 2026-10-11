#import "../config.typ": serif-fonts
#import "../utils/text.typ": bp, tex-pt

#let _circled-footnotes = (
  "⓪",
  "①",
  "②",
  "③",
  "④",
  "⑤",
  "⑥",
  "⑦",
  "⑧",
  "⑨",
  "⑩",
)

#let _footnote-style(config, body) = {
  let marker-fonts = if config.footnote-style == "circled" {
    serif-fonts(config).slice(1)
  } else {
    serif-fonts(config)
  }
  // thuthesis.dtx uses bare `\xiaowu`: 9bp with the named-size default
  // multiplier 1.3, hence an 11.7bp baseline.
  let footnote-size = bp(9)
  let footnote-baseline = footnote-size * 1.3
  // latex.ltx's `\strutbox` depth is 30% of the active baseline. Each
  // footnote ends with that strut, so it is both the one-line box depth and
  // the distance between consecutive entry frames in Typst's model.
  let footnote-strut-depth = 0.3 * footnote-baseline
  set footnote(numbering: n => if config.footnote-style == "plain" {
    str(n)
  } else if n < _circled-footnotes.len() {
    _circled-footnotes.at(n)
  } else {
    str(n)
  })
  set footnote.entry(
    // LaTeX's -3pt/0.4pt/2.6pt rule has zero layout height. Place the rule
    // 3pt above the first footnote line box instead of compensating a moved
    // text baseline with an unrelated fitted offset.
    separator: block(height: 0pt, place(
      top + left,
      // Typst inserts `gap` before the first entry as well as between later
      // entries. Start from that first entry's top edge, then reproduce
      // TeX's -3pt skip and convert the rule's top edge to a stroke center.
      dy: footnote-strut-depth - tex-pt(3) + tex-pt(0.4) / 2,
      line(length: 30%, stroke: tex-pt(0.4)),
    )),
    // LaTeX's 12pt book class sets `\skip\footins` to 10.8pt. The
    // separator's -3pt/0.4pt/2.6pt dimensions cancel, so this clearance is
    // the full reserved distance between the body and the footnote area.
    clearance: tex-pt(10.8),
    gap: footnote-strut-depth,
    indent: 0pt,
  )
  show footnote.entry: set block(breakable: false)
  show footnote.entry: it => {
    // `\footnotesep` is the height of TeX's footnote strut. Its baseline is
    // the bottom edge, so glyph depth may extend into the bottom margin.
    set text(
      size: footnote-size,
      top-edge: tex-pt(8.4),
      bottom-edge: "baseline",
    )
    // `\xiaowu` uses a 11.7bp baseline. With the explicit 8.4pt strut,
    // leading is the remainder rather than the former generic 0.3em.
    set par(
      leading: footnote-baseline - tex-pt(8.4),
      spacing: footnote-baseline - tex-pt(8.4),
    )
    // Body lists reproduce LaTeX's first-level left margin below. Keep
    // list markup inside a footnote on Typst's existing compact geometry.
    set list(indent: 0pt, body-indent: 0.5em)
    set enum(indent: 0pt, body-indent: 0.5em)
    let location = it.note.location()
    // thuthesis.dtx fixes `\footnotemargin` at 13.5bp. Model it directly
    // as the marker column so the marker starts at the rule and every body
    // line starts exactly one margin later.
    grid(
      columns: (bp(13.5), 1fr),
      inset: 0pt,
      text(
        font: marker-fonts,
        size: footnote-size,
        link(
          location,
          counter(footnote).display(it.note.numbering, at: location),
        ),
      ),
      it.note.body,
    )
  }
  body
}

#import "../config.typ": chapter-names, chinese, is-graduate
#import "../layouts/headings.typ": heading-style
#import "../layouts/runtime.typ": reset-achievements, step-achievements
#import "common.typ": special-chapter
#import "../utils/text.typ": bp, line-height

#let resume(config, title: auto, header: auto, body) = {
  if config.anonymous { return }
  special-chapter(
    if title == auto { chapter-names(config).resume } else { title },
    header: header,
  )
  if config.degree == "bachelor" and not chinese(config) {
    set text(
      font: config.fonts.HeiTi,
      size: bp(15),
      top-edge: 0.8em,
      bottom-edge: -0.2em,
    )
    set par(leading: bp(5), spacing: bp(5))
  }
  reset-achievements()
  heading-style(config, body, variant: "resume")
}

#let achievements(config, items) = {
  let zh = chinese(config)
  let size = if not zh and config.degree == "bachelor" { bp(15) } else {
    bp(12)
  }
  let baseline = if zh and is-graduate(config) { bp(16) } else { bp(20) }
  let item-sep = if zh { bp(6) } else { 0pt }
  step-achievements(items.len(), start => line-height(size, baseline, {
    enum(
      ..items.map(it => [#it]),
      start: start,
      numbering: n => box(
        width: if zh { 1cm } else { 1.25cm },
        align(
          if zh { left } else { right },
          text(font: config.fonts.SongTi.first(), lang: "en", numbering(
            "[1]",
            n,
          )),
        ),
      ),
      spacing: baseline - size + item-sep,
      indent: 0pt,
      body-indent: if zh { 0pt } else { 0.5cm },
    )
    if item-sep != 0pt { v(item-sep, weak: false) }
  }))
}

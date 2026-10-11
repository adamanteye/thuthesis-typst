#import "../config.typ": chapter-names, chinese, is-graduate, sans-fonts, serif-fonts
#import "../layouts/runtime.typ": thuthesis-runtime
#import "common.typ": _inside, _special-chapter
#import "../utils/text.typ": bp, line-height

#let _resume(env, title: auto, header: auto, body) = _inside(env, config => {
  if config.anonymous { return }
  _special-chapter(
    env,
    if title == auto { chapter-names(config).resume } else { title },
    header: header,
  )
  if config.degree == "bachelor" and not chinese(config) {
    set text(
      font: sans-fonts(config),
      size: bp(15),
      top-edge: 0.8em,
      bottom-edge: -0.2em,
    )
    set par(leading: bp(5), spacing: bp(5))
  }
  (thuthesis-runtime.reset-achievements)()
  (env.layout.heading-style)(body, variant: "resume")
})

#let _achievements(env, items) = _inside(env, config => {
  let chinese-mode = chinese(config)
  let graduate-zh = chinese-mode and is-graduate(config)
  let size = if not chinese-mode and config.degree == "bachelor" {
    bp(15)
  } else { bp(12) }
  let baseline = if graduate-zh { bp(16) } else { bp(20) }
  let item-sep = if chinese-mode { bp(6) } else { 0pt }
  let label-width = if chinese-mode { 1cm } else { 1.25cm }
  let label-gap = if chinese-mode { 0pt } else { 0.5cm }
  let label-align = if chinese-mode { left } else { right }
  (thuthesis-runtime.achievements)(items.len(), start => line-height(
    size,
    baseline,
    {
      enum(
        ..items.map(it => [#it]),
        start: start,
        numbering: n => box(
          width: label-width,
          align(label-align, text(
            font: serif-fonts(config).first(),
            lang: "en",
            numbering("[1]", n),
          )),
        ),
        spacing: baseline - size + item-sep,
        indent: 0pt,
        body-indent: label-gap,
      )
      // LaTeX's list `topsep` is present on both sides. Typst collapses a
      // block's lower spacing with the following heading, so preserve this
      // source list parameter as content at the list boundary.
      if item-sep != 0pt { v(item-sep, weak: false) }
    },
  ))
})

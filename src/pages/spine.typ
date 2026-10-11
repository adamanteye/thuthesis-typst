#import "../config.typ": fangsong-fonts
#import "../layouts/pagebreak.typ": clear-page
#import "../utils/text.typ": bp, stretch-text

#let spine-page(config) = {
  let title = if config.spine-title == auto {
    config.info.title
  } else { config.spine-title }
  let author = if config.spine-author == auto {
    config.info.author
  } else { config.spine-author }
  let font-size = if config.spine-font != auto {
    config.spine-font
  } else if config.degree == "doctor" {
    bp(16)
  } else {
    bp(15)
  }
  let text-height = if config.degree == "bachelor" { 23.7cm } else { 18.7cm }
  set page(
    paper: "a4",
    margin: (
      top: if config.degree == "bachelor" { 3cm } else { 5.5cm },
      bottom: if config.degree == "bachelor" { 3cm } else { 5.5cm },
      left: 1cm,
      right: 1cm,
    ),
    header: none,
    footer: none,
    numbering: none,
  )
  align(right + horizon, rotate(
    -90deg,
    origin: top + left,
    reflow: true,
    block(width: text-height, height: 1.5em)[
      #set text(
        font: fangsong-fonts(config),
        size: font-size,
        features: ("vert",),
      )
      // Typst's transformed frame runs opposite to graphicx's `lt` origin;
      // reverse the two anchors so the rendered spine still reads title at
      // the physical top and author at the physical bottom.
      #place(right + horizon, title)
      #place(left + horizon, stretch-text(4.5em, author))
    ],
  ))
  clear-page()
}

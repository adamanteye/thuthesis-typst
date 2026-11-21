#import "common.typ": cover-page
#import "../utils/text.typ": bp, stretch-text

#let spine-page(config) = {
  let title = if config.spine-title == auto { config.info.title } else {
    config.spine-title
  }
  let author = if config.spine-author == auto { config.info.author } else {
    config.spine-author
  }
  let font-size = if config.spine-font != auto {
    config.spine-font
  } else if config.degree == "doctor" { bp(16) } else { bp(15) }
  let bachelor = config.degree == "bachelor"
  let v-margin = if bachelor { 3cm } else { 5.5cm }
  cover-page((top: v-margin, bottom: v-margin, x: 1cm), align(
    right + horizon,
    rotate(
      -90deg,
      origin: top + left,
      reflow: true,
      block(width: if bachelor { 23.7cm } else { 18.7cm }, height: 1.5em)[
        #set text(font: config.fonts.FangSong, size: font-size, features: (
          "vert",
        ))
        #place(right + horizon, title)
        #place(left + horizon, stretch-text(4.5em, author))
      ],
    ),
  ))
}

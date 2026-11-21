#import "../utils/text.typ": bp

#let fonts-display(config, size: bp(12)) = {
  set page(margin: auto)
  set text(size: size)
  text(fill: red)[_Check the rendered CJK and Latin text below before submitting
  a thesis._]
  for (label, role) in (
    ([正文 / Serif], "SongTi"),
    ([标题 / Sans], "HeiTi"),
    ([楷体 / Kaiti], "KaiTi"),
    ([仿宋 / FangSong], "FangSong"),
    ([等宽 / Mono], "Mono"),
  ) {
    line(length: 100%, stroke: .3pt)
    text(font: config.fonts.at(role))[
      *#label*

      落霞与孤鹜齐飞，秋水共长天一色。

      The fanfare of birds announces the morning.
    ]
  }
  pagebreak(to: "odd")
}

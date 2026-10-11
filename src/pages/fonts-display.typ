#import "common.typ": _inside
#import "../utils/text.typ": bp

/// Render a compact font diagnostic page using the active font profile.
#let _render-fonts-display(fonts, size: 12pt) = {
  set page(margin: auto)
  set text(size: size)
  text(fill: red)[
    _Check the rendered CJK and Latin text below before submitting a thesis._
  ]
  for (label, role) in (
    ([正文 / Serif], "serif"),
    ([标题 / Sans], "sans"),
    ([楷体 / Kaiti], "kaiti"),
    ([仿宋 / FangSong], "fangsong"),
    ([等宽 / Mono], "mono"),
  ) {
    line(length: 100%, stroke: .3pt)
    text(font: fonts.at(role))[
      *#label*

      落霞与孤鹜齐飞，秋水共长天一色。

      The fanfare of birds announces the morning.
    ]
  }
  pagebreak(to: "odd")
}

#let _fonts-display(env, size: bp(12)) = _inside(
  env,
  config => _render-fonts-display(config.font-profile, size: size),
)

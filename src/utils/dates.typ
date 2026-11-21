#let _digits = "〇一二三四五六七八九".clusters()
#let _months-zh = (
  "一",
  "二",
  "三",
  "四",
  "五",
  "六",
  "七",
  "八",
  "九",
  "十",
  "十一",
  "十二",
)

#let date-zh(value) = (
  str(value.year()).clusters().map(c => _digits.at(int(c))).join()
    + "年"
    + _months-zh.at(value.month() - 1)
    + "月"
)

#let date-zh-digits(value, day: true) = value.display(
  if day { "[year] 年 [month padding:none] 月 [day padding:none] 日" } else {
    "[year] 年 [month padding:none] 月"
  },
)

#let date-en(value) = value.display("[month repr:long], [year]")

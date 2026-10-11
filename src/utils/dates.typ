#let _digits = (
  "0": "〇",
  "1": "一",
  "2": "二",
  "3": "三",
  "4": "四",
  "5": "五",
  "6": "六",
  "7": "七",
  "8": "八",
  "9": "九",
)
#let _months-en = (
  "January",
  "February",
  "March",
  "April",
  "May",
  "June",
  "July",
  "August",
  "September",
  "October",
  "November",
  "December",
)
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

#let _parts(value) = (value.year(), value.month(), value.day())

#let date-zh(value, day: false) = {
  let (year, month, date-day) = _parts(value)
  let result = (
    str(year).clusters().map(it => _digits.at(it)).join()
      + "年"
      + _months-zh.at(month - 1)
      + "月"
  )
  if day { result + str(date-day) + "日" } else { result }
}

#let date-zh-digits(value, day: true) = {
  let (year, month, date-day) = _parts(value)
  let result = str(year) + " 年 " + str(month) + " 月"
  if day { result + " " + str(date-day) + " 日" } else { result }
}

#let date-en(value) = {
  let (year, month, _) = _parts(value)
  _months-en.at(month - 1) + ", " + str(year)
}

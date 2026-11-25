// #import "@preview/tntt:0.6.0" as tntt
#import "../src/lib.typ" as tntt
#import tntt: define-config
#import "abstract.typ": render-abstract
#import "acknowledgements.typ": acknowledgements-content
#import "comments.typ": comments-content
#import "committee.typ": committee-content
#import "notation.typ": denotation-entries
#import "en/notation.typ": denotation-entries as denotation-entries-en
#import "resolution.typ": resolution-content
#import "resume.typ": resume-content

// 封面采用双语资料，正文语言由命令行的 language 选项决定。
#let language = sys.inputs.at("language", default: "chinese")
#let english = language == "english"
#let (
  meta,
  cover,
  cover-en,
  doc,
  committee,
  copyright,
  front-matter,
  abstract,
  abstract-en,
  outline-wrapper,
  figure-list,
  table-list,
  notation,
  main-matter,
  bibliography-thu,
  appendix,
  back-matter,
  acknowledge,
  declaration,
  achievement,
  achievements,
  comments,
  resolution,
  ..,
) = define-config(
  // 盲审模式，启用后会隐藏作者信息和部分页面
  anonymous: false,
  degree: "master",
  degree-type: "academic",
  language: language,
  twoside: (electronic: false, print: true).at(sys.inputs.at(
    "output",
    default: "electronic",
  )),
  thesis-type: sys.inputs.at("thesis-type", default: "thesis"),
  style-override: sys.inputs.at("style-override", default: "none"),
  info: (
    title: ("清华大学学位论文 Typst 模板", "使用示例文档 v0.1.0"),
    title-en: [An Introduction to Typst Thesis Template of Tsinghua University
      v0.1.0],
    metadata-title: "清华大学学位论文 Typst 模板使用示例文档",
    degree-name: [工学硕士],
    degree-name-en: [Master of Science],
    department: [计算机科学与技术系],
    major: [计算机科学与技术],
    major-en: [Computer Science and Technology],
    professional-field: [计算机技术],
    professional-field-en: [Computer Technology],
    student-id: [2026000000],
    author: [薛瑞尼],
    author-en: [Xue Ruini],
    supervisor: ([郑纬民], [教授]),
    // 多指导老师示例
    // supervisor: ("某某某", "教授", "某某", "副教授"),
    supervisor-en: ([Zheng Weimin], [Professor]),
    // 联合指导教师/副指导教师，通常本科生不填写
    associate-supervisor: ([陈文光], [教授]),
    associate-supervisor-en: ([Chen Wenguang], [Professor]),
    date: datetime(year: 2026, month: 8, day: 8),
    clc: [TP3],
    udc: [004],
    id: [2026-01],
    discipline-level-1: [Computer Science and Technology],
    discipline-level-2: [Computer Systems Architecture],
    // day is ignored in thesis, however required to make typst happy
    start-date: datetime(year: 2024, month: 8, day: 1),
    end-date: datetime(year: 2026, month: 7, day: 31),
  ),
  fonts: sys.inputs.at("font-profile", default: "fandol"),
)

#show: meta
#cover()
#cover-en()
#show: doc

#committee(title: [学位论文指导小组、公开评阅人和答辩委员会名单])[
  #committee-content
]

// 使用授权说明。签字扫描件可改为：
// #copyright(file: read("fig/scan-copyright.pdf", encoding: none))
#copyright()

#front-matter[
  #render-abstract(abstract, abstract-en)

  #outline-wrapper()
  #figure-list()
  #table-list()

  #notation(
    if english { denotation-entries-en } else { denotation-entries },
    label-width: 3cm,
  )
]

#main-matter[
  #if english [
    #include "en/chap01.typ"
    #include "en/chap02.typ"
    #include "en/chap03.typ"
    #include "en/chap04.typ"
  ] else [
    #include "writing.typ"
    #include "figures.typ"
    #include "mathematics.typ"
    #include "citations.typ"
  ]

  #bibliography-thu(read("main.bib", encoding: none), full: true)
]

#appendix[
  #if english { include "en/appendix.typ" } else { include "appendix.typ" }
  #bibliography-thu(read("appendix.bib", encoding: none), group: none)
]

#back-matter[
  #acknowledge(if english {
    include "en/acknowledgements.typ"
  } else { acknowledgements-content })
  // 中英文论文均使用中文声明。提交签字扫描页时，可将下一行替换为
  // #declaration(file: read("fig/scan-statement.pdf", encoding: none))
  #declaration()
  #achievement[#resume-content(achievements)]
  #comments(if english { include "en/comments.typ" } else {
    comments-content
  })
  #resolution(if english { include "en/resolution.typ" } else {
    resolution-content
  })
]

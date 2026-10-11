#import "../src/lib.typ": define-config

#let degree = sys.inputs.at("degree")
#let language = sys.inputs.at("language")
#let output = sys.inputs.at("output")
#let degree-type = sys.inputs.at("degree-type", default: "academic")
#let thesis-type = sys.inputs.at("thesis-type", default: "thesis")
#let style-override = sys.inputs.at("style-override", default: "none")
#let lang = if language == "chinese" { "zh" } else { "en" }

#let text = (
  zh: (
    title: "论文模板视觉对比",
    chapter: "比较章节",
    body: "这是用于检查正文、页眉、页码和章节编号的示例文字。",
    section: "图表与公式",
    figure: "示例图",
    table: "示例表",
    appendix: "附录测试",
    appendix-body: "这是用于检查附录编号和页眉的示例文字。",
  ),
  en: (
    title: "Visual Comparison of Thesis Templates",
    chapter: "Comparison Chapter",
    body: "This text checks the body, header, page number, and chapter number.",
    section: "Figures, Tables, and Equations",
    figure: "Example figure",
    table: "Example table",
    appendix: "Appendix Test",
    appendix-body: "This text checks appendix numbering and running headers.",
  ),
).at(lang)

#let (
  meta, cover, cover-en, doc,
  front-matter, abstract, abstract-en, outline-wrapper,
  main-matter, appendix, ..
) = define-config(
  degree: degree,
  degree-type: degree-type,
  language: language,
  twoside: (electronic: false, print: true).at(output),
  thesis-type: thesis-type,
  style-override: style-override,
  fonts: "fandol",
  info: (
    title: [论文模板视觉对比],
    title-en: [Visual Comparison of Thesis Templates],
    degree-name: [工学学位],
    degree-name-en: [Degree of Engineering],
    department: [计算机科学与技术系],
    major: [计算机科学与技术],
    major-en: [Computer Science and Technology],
    professional-field: [计算机技术],
    professional-field-en: [Computer Technology],
    author: [测试作者],
    author-en: [Test Author],
    student-id: [2026000000],
    supervisor: ([测试导师], [教授]),
    supervisor-en: ([Test Supervisor], [Professor]),
    date: datetime(year: 2026, month: 8, day: 8),
    clc: [TP3],
    udc: [004],
    id: [2026-01],
    discipline-level-1: [计算机科学与技术],
    discipline-level-2: [计算机系统结构],
    start-date: datetime(year: 2024, month: 8, day: 1),
    end-date: datetime(year: 2026, month: 7, day: 31),
  ),
)

#show: meta
#cover()
#cover-en()
#show: doc

#front-matter[
  #abstract(keywords: ([模板], [对比]))[
    本文用于比较 LaTeX 与 Typst 模板在不同论文配置下的版式。
  ]
  #abstract-en(keywords: ([template], [comparison]))[
    This document compares the LaTeX and Typst layouts under different thesis
    configurations.
  ]
  #outline-wrapper()
]

#main-matter[

  = #text.chapter

  #text.body

  == #text.section

  #figure(rect(width: 3cm, height: 1cm), caption: text.figure)

  #figure(
    table(
      columns: 2,
      [Item], [Value],
      [A], [1],
    ),
    kind: table,
    caption: text.table,
  )

  $ E = m c^2 $

]

#appendix[

  = #text.appendix

  #text.appendix-body

]

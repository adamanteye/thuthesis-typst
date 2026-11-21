#import "../config.typ": chapter-names, is-graduate
#import "../layouts/page.typ": page-footer, page-header
#import "common.typ": signature-line, special-chapter
#import "scanned.typ": scanned-pages
#import "../utils/text.typ": bp, line-height

#let statement(config, file: none, page-style: "plain") = {
  if config.anonymous { return }
  let title = special-chapter(
    chapter-names(config).statement,
    kind: "statement",
  )
  if file != none {
    return scanned-pages(config, file, page-style: page-style, anchor: title)
  }
  // ThuThesis uses Chinese for the statement regardless of thesis language.
  set text(lang: "zh", region: "CN")
  set par(linebreaks: "simple")
  set page(
    header: if page-style == "plain" { page-header(config) } else { none },
    footer: if page-style == "plain" { page-footer(config) } else { none },
    numbering: if page-style == "plain" { "1" } else { none },
  )
  title
  if is-graduate(config) {
    v(bp(13))
    line-height(bp(12), bp(21), text(tracking: bp(0.15))[
      本人郑重声明：所呈交的学位论文，是本人在导师指导下，独立进行研究工作所取得的成果#if (
        config.info.at("secret-level", default: none) == none
      ) [，不包含涉及国家秘密的内容]。尽我所知，除文中已经注明引用的内容外，本学位论文的研究成果不包含任何他人享有著作权的内容。对本论文所涉及的研究工作做出贡献的其他个人和集体，均已在文中以明确方式标明。
    ])
    v(bp(78.5) + bp(18) - 0.2 * bp(12) - 0.8 * bp(13) - (bp(21) - bp(12)))
    pad(left: bp(153.5), line-height(bp(13), bp(18))[
      签#h(1em)名：#signature-line(bp(13), bp(76))#h(-bp(3))日#h(
        1em,
      )期：#signature-line(bp(13), bp(65), trailing: false)
    ])
  } else if config.degree == "bachelor" {
    text(tracking: bp(0.1))[
      本人郑重声明：所呈交的综合论文训练论文，是本人在导师指导下，独立进行研究工作所取得的成果。尽我所知，除文中已经注明引用的内容外，本论文的研究成果不包含任何他人享有著作权的内容。对本论文所涉及的研究工作做出贡献的其他个人和集体，均已在文中以明确方式标明。
    ]
    v(bp(40))
    align(right)[
      签#h(0.5em)名：#signature-line(bp(12), 2.75cm)#h(0.5em)日#h(
        0.5em,
      )期：#signature-line(bp(12), 2.75cm, trailing: false)
    ]
  }
}

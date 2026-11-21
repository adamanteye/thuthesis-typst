#import "../layouts/headings.typ": heading-style
#import "../layouts/page.typ": clear-double-page
#import "common.typ": signature-line
#import "scanned.typ": scanned-pages
#import "../utils/text.typ": bp, line-height

#let _authorization-body(config) = {
  set page(header: none, footer: none, numbering: none)
  let bachelor = config.degree == "bachelor"
  heading-style(
    config,
    variant: if bachelor { "authorization-bachelor" } else {
      "authorization-graduate"
    },
    {
      heading(level: 1, numbering: none, outlined: false)[
        #if bachelor [关于论文使用授权的说明] else [关于学位论文使用授权的说明]
      ]
    },
  )
  v(bp(13))
  line-height(bp(14), bp(26), if bachelor [
    本人完全了解清华大学有关保留、使用综合论文训练论文的规定，即：学校有权保留论文的复印件，允许论文被查阅和借阅；学校可以公布论文的全部或部分内容，可以采用影印、缩印或其他复制手段保存论文。
  ] else [
    本人完全了解清华大学有关保留、使用学位论文的规定，即：

    清华大学拥有在著作权法规定范围内学位论文的使用权，其中包括：（1）已获学位的研究生必须按学校规定提交学位论文，学校可以采用影印、缩印或其他复制手段保存研究生上交的学位论文；（2）为教学和科研目的，学校可以将公开的学位论文作为资料在图书馆、资料室等场所供校内师生阅读，或在校园网上供校内师生浏览部分内容；（3）根据《中华人民共和国学位法》及上级教育主管部门要求，报送相应的学位论文。

    本人保证遵守上述规定。
  ])
  if bachelor {
    v(bp(71) + bp(18) - 0.2 * bp(14) - 0.8 * bp(12) - (bp(26) - bp(14)))
    pad(left: bp(42), line-height(bp(12), bp(18))[
      #set par(first-line-indent: 0pt)
      作者签名：#h(bp(118))导师签名：
      #v(bp(11))
      日#h(2em)期：#h(bp(118))日#h(2em)期：
    ])
  } else {
    v(bp(33) + bp(23.4) - 0.2 * bp(14) - 0.8 * bp(12) - (bp(26) - bp(14)))
    pad(left: bp(43), line-height(bp(12), bp(23.4))[
      #set par(first-line-indent: 0pt)
      作者签名：#h(bp(4))#signature-line(bp(12), 7em)#h(bp(47))导师签名：#h(
        bp(4),
      )#signature-line(bp(12), 7em, trailing: false)
      #v(bp(6))
      日#h(2em)期：#h(bp(4))#signature-line(bp(12), 7em)#h(bp(47))日#h(
        2em,
      )期：#h(bp(4))#signature-line(bp(12), 7em, trailing: false)
    ])
  }
  pagebreak()
}

#let authorization(config, file: none) = if (
  config.degree != "postdoc" and not config.anonymous
) {
  clear-double-page(config)
  if file != none { scanned-pages(config, file) } else {
    _authorization-body(config)
  }
}

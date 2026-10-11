#import "../layouts/pagebreak.typ": clear-double-page, clear-page
#import "common.typ": _inside, _once, _signature-line
#import "scanned.typ": _scanned-pages
#import "../utils/text.typ": bp, line-height, tex-vlist-boundary

#let _authorization(config, env) = {
  set page(header: none, footer: none, numbering: none)
  if config.degree == "bachelor" {
    (env.layout.heading-style)(variant: "authorization-bachelor", {
      heading(level: 1, numbering: none, outlined: false)[
        关于论文使用授权的说明
      ]
    })
    v(bp(13))
    line-height(bp(14), bp(26))[
      本人完全了解清华大学有关保留、使用综合论文训练论文的规定，即：学校有权保留论文的复印件，允许论文被查阅和借阅；学校可以公布论文的全部或部分内容，可以采用影印、缩印或其他复制手段保存论文。
    ]
    v(
      tex-vlist-boundary(
        bp(18),
        0.2 * bp(14),
        0.8 * bp(12),
        skip: bp(71),
      ).spacing
        - (bp(26) - bp(14)),
    )
    pad(left: bp(42), line-height(bp(12), bp(18))[
      #set par(first-line-indent: 0pt)
      作者签名：#h(bp(118))导师签名：
      #v(bp(11))
      日#h(2em)期：#h(bp(118))日#h(2em)期：
    ])
  } else {
    (env.layout.heading-style)(variant: "authorization-graduate", {
      heading(level: 1, numbering: none, outlined: false)[
        关于学位论文使用授权的说明
      ]
    })
    v(bp(13))
    line-height(bp(14), bp(26))[
      本人完全了解清华大学有关保留、使用学位论文的规定，即：

      清华大学拥有在著作权法规定范围内学位论文的使用权，其中包括：（1）已获学位的研究生必须按学校规定提交学位论文，学校可以采用影印、缩印或其他复制手段保存研究生上交的学位论文；（2）为教学和科研目的，学校可以将公开的学位论文作为资料在图书馆、资料室等场所供校内师生阅读，或在校园网上供校内师生浏览部分内容；（3）根据《中华人民共和国学位法》及上级教育主管部门要求，报送相应的学位论文。

      本人保证遵守上述规定。
    ]
    // TeX inserts the new paragraph with its 23.4bp baselineskip after the
    // explicit 33bp skip. Remove the 14bp paragraph's existing Typst spacing
    // before converting that baseline boundary to an edge gap.
    v(
      tex-vlist-boundary(
        bp(23.4),
        0.2 * bp(14),
        0.8 * bp(12),
        skip: bp(33),
      ).spacing
        - (bp(26) - bp(14)),
    )
    pad(left: bp(43), line-height(bp(12), bp(23.4))[
      #set par(first-line-indent: 0pt)
      作者签名：#h(bp(4))#_signature-line(bp(12), 7em)#h(bp(47))导师签名：#h(bp(4))#_signature-line(bp(12), 7em, trailing: false)
      #v(bp(6))
      日#h(2em)期：#h(bp(4))#_signature-line(bp(12), 7em)#h(bp(47))日#h(2em)期：#h(bp(4))#_signature-line(bp(12), 7em, trailing: false)
    ])
  }
  clear-page()
}

#let _authorization-component(env, file: none) = _inside(env, config => {
  if config.degree != "postdoc" and not config.anonymous {
    _once("authorization", {
      clear-double-page(config, weak: true)
      if file != none { _scanned-pages(env, file) } else {
        _authorization(config, env)
      }
    })
  }
})

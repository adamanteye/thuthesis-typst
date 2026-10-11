#import "../utils/text.typ": bp, tex-pt

#let _body-font-size = bp(12)

#let _body-baseline = bp(20)

// TeX positions a continuation page's first baseline with `\topskip`.
// With ThuThesis's 12bp text and 0.8em top edge, the corresponding inset is
// 12 TeX pt - 9.6bp. Typst otherwise starts the ink at the page body edge.
#let _body-top-skip = tex-pt(12) - 0.8 * _body-font-size

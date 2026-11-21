// Document-scoped state shared across matter transitions, headers, and headings.

#let _runtime = state("thuthesis.runtime", (
  matter: "title",
  heading-kind: "body",
  heading-header: auto,
  after-heading: none,
  achievements: 0,
))

#let runtime-at(location) = _runtime.at(location)

#let transition(matter) = _runtime.update(cur => (
  cur
    + (
      matter: matter,
      heading-kind: "body",
      heading-header: auto,
      after-heading: none,
    )
))

#let special-heading(kind, header, body) = {
  _runtime.update(cur => cur + (heading-kind: kind, heading-header: header))
  body
  _runtime.update(cur => cur + (heading-kind: "body", heading-header: auto))
}

#let mark-after-heading(kind, figure-correction: 0pt) = _runtime.update(cur => (
  cur + (after-heading: (kind: kind, figure-correction: figure-correction))
))

#let clear-after-heading() = _runtime.update(cur => cur + (after-heading: none))

#let reset-achievements() = _runtime.update(cur => cur + (achievements: 0))

#let step-achievements(count, render) = context {
  let start = _runtime.get().achievements + 1
  _runtime.update(cur => cur + (achievements: cur.achievements + count))
  render(start)
}

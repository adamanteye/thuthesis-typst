#import "text.typ": stretch-text

#let _person(value) = if type(value) == dictionary {
  value
} else {
  (name: value, title: none)
}

#let graduate-person(value) = {
  let person = _person(value)
  box(width: 3cm, align(left, stretch-text(4em, person.name)))
  if person.title != none { stretch-text(3em, person.title) }
}

#let bachelor-person(value) = {
  let person = _person(value)
  stretch-text(4em, person.name)
  if person.title != none {
    h(1.5em)
    stretch-text(2.5em, person.title)
  }
}

#let english-person(person) = {
  if person.title != none {
    person.title
    text(" ")
  }
  person.name
}

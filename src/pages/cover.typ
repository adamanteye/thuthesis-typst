#import "../layouts/pagebreak.typ": clear-double-page
#import "cover-bachelor.typ": _bachelor-cover
#import "cover-english.typ": _english-title-page
#import "cover-graduate.typ": _graduate-cover
#import "cover-postdoc.typ": _postdoc-cover, _postdoc-title-page
#import "spine.typ": spine-page

#let first-title-page(config) = {
  counter(page).update(1)
  clear-double-page(config, weak: true)
  if config.degree == "bachelor" {
    _bachelor-cover(config)
  } else if config.degree == "postdoc" {
    _postdoc-cover(config)
  } else {
    _graduate-cover(config)
  }
  if config.include-spine and not config.anonymous and config.degree != "postdoc" { spine-page(config) }
}

#let second-title-page(config) = {
  if config.degree == "postdoc" {
    clear-double-page(config, weak: true)
    _postdoc-title-page(config)
    if config.include-spine and not config.anonymous { spine-page(config) }
  } else if config.degree != "bachelor" and config.thesis-type == "thesis" {
    clear-double-page(config, weak: true)
    _english-title-page(config)
  }
}

#import "../layouts/page.typ": clear-double-page
#import "cover-bachelor.typ": bachelor-cover
#import "cover-english.typ": english-title-page
#import "cover-graduate.typ": graduate-cover
#import "cover-postdoc.typ": postdoc-cover, postdoc-title-page
#import "spine.typ": spine-page

#let first-title-page(config) = {
  counter(page).update(1)
  clear-double-page(config)
  if config.degree == "bachelor" {
    bachelor-cover(config)
  } else if config.degree == "postdoc" {
    postdoc-cover(config)
  } else {
    graduate-cover(config)
  }
  if (
    config.include-spine and not config.anonymous and config.degree != "postdoc"
  ) { spine-page(config) }
}

#let second-title-page(config) = {
  if config.degree == "postdoc" {
    clear-double-page(config)
    postdoc-title-page(config)
    if config.include-spine and not config.anonymous { spine-page(config) }
  } else if config.degree != "bachelor" and config.thesis-type == "thesis" {
    clear-double-page(config)
    english-title-page(config)
  }
}

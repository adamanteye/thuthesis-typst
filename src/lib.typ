//! The main configuration file for the TNTT template.

#import "config.typ": page-options
#import "thesis.typ": thesis-config, thesis-pages, thuthesis-bib
#import "utils/font.typ": page-fonts

/// Define the configuration for the document.
///
/// - degree (str): The degree (`"bachelor"`, `"master"`, `"doctor"`, or `"postdoc"`).
/// - degree-type (str): The degree type (`"academic"` or `"professional"`).
/// - anonymous (str, bool): Whether to use anonymous mode.
/// - twoside (str, bool): Whether to use two-sided printing.
/// - bibliography (dictionary, none): Optional bilingual bibliography configured with `thuthesis-bib(...)`.
/// - fonts (str, dictionary): Font preset name or custom font-family dictionary.
/// - info (dictionary): Document metadata and cover information.
/// -> dictionary
#let define-config(
  degree: "bachelor",
  degree-type: "academic",
  anonymous: false,
  twoside: false,
  bibliography: none,
  fonts: (:),
  info: (:),
  ..options,
) = {
  degree = sys.inputs.at("degree", default: degree)
  degree-type = sys.inputs.at("degree-type", default: degree-type)
  anonymous = if sys.inputs.at("anonymous", default: anonymous) in (true, "true") { true } else { false }
  twoside = sys.inputs.at("twoside", default: twoside)

  let config = thesis-config(page-options(degree, degree-type, anonymous, twoside, fonts, info, bibliography, options))
  let fonts = page-fonts(config.font-profile)

  (
    info: config.info,
    fonts: fonts,
    degree-type: config.degree-type,
    degree: config.degree,
    twoside: twoside,
    anonymous: config.anonymous,
    ..thesis-pages(config),
  )
}

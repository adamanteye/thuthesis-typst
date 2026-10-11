//! Font role mapping helpers.

#let _profile-roles = (SongTi: "serif", HeiTi: "sans", KaiTi: "kaiti", FangSong: "fangsong", Mono: "mono", Math: "math")
#let page-fonts(profile) = _profile-roles.pairs().map(((family, role)) => (family, profile.at(role))).to-dict()
#let page-font-profile(fonts) = _profile-roles.pairs().map(((family, role)) => (role, fonts.at(family))).to-dict()

#let _unwrap-font(font) = if type(font) == str { font } else { font.name }

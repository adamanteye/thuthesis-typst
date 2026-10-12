{
  description = "TnTT development and CI toolchain";

  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
  # Upstream nixpkgs does not yet provide TeX Live 2026.
  inputs.texlive-nixpkgs.url = "github:chrjabs/nixpkgs/texlive-2026";

  outputs =
    { nixpkgs, texlive-nixpkgs, ... }:
    let
      systems = [
        "x86_64-linux"
        "aarch64-linux"
        "aarch64-darwin"
      ];
    in
    {
      devShells = nixpkgs.lib.genAttrs systems (
        system:
        let
          pkgs = nixpkgs.legacyPackages.${system};
          texPkgs = texlive-nixpkgs.legacyPackages.${system};
          tex = texPkgs.texliveSmall.withPackages (
            ps: with ps; [
              latexmk
              xetex
              ctex
              xecjk
              fandol
              tex-gyre
              xits
              newcomputermodern
              algorithms
              bibunits
              caption
              enumitem
              environ
              fancyhdr
              filehook
              footmisc
              notoccite
              pdfpages
              siunitx
              titlesec
              ulem
              multirow
              threeparttable
              unicode-math
            ]
          );
          fontDir = "${tex}/share/texmf/fonts";
          fontConfig = pkgs.writeText "thuthesis-fonts.conf" ''
            <?xml version="1.0"?>
            <!DOCTYPE fontconfig SYSTEM "urn:fontconfig:fonts.dtd">
            <fontconfig>
              <dir>${fontDir}</dir>
              <cachedir prefix="xdg">fontconfig</cachedir>
            </fontconfig>
          '';
        in
        assert nixpkgs.lib.assertMsg (nixpkgs.lib.hasPrefix "texlive-2026-" tex.name)
          "The TnTT toolchain requires TeX Live 2026.";
        assert nixpkgs.lib.assertMsg (
          pkgs.typst.version == "0.15.1"
        ) "The TnTT toolchain requires Typst 0.15.1.";
        {
          default = pkgs.mkShellNoCC {
            packages = [
              pkgs.typst
              tex
              pkgs.fontconfig
              pkgs.just
            ];
            TYPST_FONT_PATHS = fontDir;
            TYPST_IGNORE_SYSTEM_FONTS = "true";
            FONTCONFIG_FILE = fontConfig;
          };
        }
      );
    };
}

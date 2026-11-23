{
  description = "TnTT development and CI toolchain";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-parts.url = "github:hercules-ci/flake-parts";
  };

  outputs =
    inputs@{ self, flake-parts, ... }:
    flake-parts.lib.mkFlake { inherit inputs; } {
      systems = [
        "x86_64-linux"
        "aarch64-linux"
        "aarch64-darwin"
      ];

      perSystem =
        { pkgs, ... }:
        let
          tex = pkgs.texliveSmall.withPackages (
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
              bigfoot
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
              thuthesis
            ]
          );
          texOf =
            pkg:
            pkgs.lib.findFirst (p: pkgs.lib.hasSuffix "-tex" p.name) (
              throw "missing -tex output for texlive package"
            ) pkg.pkgs;
        in
        {
          packages.open-fonts = pkgs.linkFarm "tntt-open-fonts" [
            {
              name = "fandol";
              path = "${texOf pkgs.texlive.fandol}/fonts/opentype/public/fandol";
            }
            {
              name = "tex-gyre";
              path = "${texOf pkgs.texlive.tex-gyre}/fonts/opentype/public/tex-gyre";
            }
            {
              name = "xits";
              path = "${texOf pkgs.texlive.xits}/fonts/opentype/public/xits";
            }
          ];

          devShells.default = pkgs.mkShellNoCC {
            packages = with pkgs; [
              tex
              typst
              just
              typstyle
              (python3.withPackages (ps: [ ps.pillow ps.pymupdf ]))
            ];
            TYPST_FONT_PATHS = tex.fonts;
            TYPST_IGNORE_SYSTEM_FONTS = "true";
          };
        };
    };
}

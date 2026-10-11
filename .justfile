root := justfile_dir()

export TYPST_ROOT := root

# list all available recipes
[private]
default:
  @just --list --unsorted

# build pdf (optionally `just build english`)
build language="chinese":
  @typst c --root . --input language={{language}} template/thesis.typ

# render the Chinese undergraduate cover for the package preview
thumbnail:
  @typst c -f png --pages 1 --root . --input degree=bachelor --input language=chinese template/thesis.typ thumbnail.png

# export profile
profile:
  @typst c --root . template/thesis.typ --timings record.json

# format typst files
format:
  @typstyle -i --line-width 120 --indent-width 2 --no-reorder-import-items src template

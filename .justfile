# list all available recipes
[private]
default:
  @just --list --unsorted

# use local open fonts when present
font-path := `test -d fonts && echo "--font-path fonts" || true`

# build pdf (optionally `just build en`)
build lang="":
  @typst c --root . {{font-path}} {{ if lang == "" { "" } else { "--input lang=" + lang } }} template/thesis.typ

# update thumbnail
thumbnail:
  @typst c -f png --pages 3 --root . {{font-path}} template/thesis.typ thumbnail.png

# export profile
profile:
  @typst c --root . {{font-path}} template/thesis.typ --timings record.json

# compile the degree/lang/anonymous/twoside matrix (35 pdfs)
smoke dest="build/nightly":
  #!/usr/bin/env bash
  set -euo pipefail
  mkdir -p "{{dest}}"
  for degree in bachelor master doctor postdoc; do
    for lang in zh en; do
      for anonymous in false true; do
        for twoside in false true; do
          name="$degree-academic-$lang"
          [[ "$anonymous" == true ]] && name+="-anonymous"
          [[ "$twoside" == true ]] && name+="-twoside"
          typst compile --root . {{font-path}} \
            --input "degree=$degree" --input "lang=$lang" \
            --input "anonymous=$anonymous" --input "twoside=$twoside" \
            template/thesis.typ "{{dest}}/$name.pdf"
        done
      done
    done
  done
  for lang in zh en; do
    typst compile --root . {{font-path}} --input "lang=$lang" \
      contrib/latex-parity/main.typ "{{dest}}/reference-$lang.pdf"
  done
  typst compile --root . {{font-path}} contrib/writing-packages.typ \
    "{{dest}}/writing-packages.pdf"

# build original PDFs against a pinned ThuThesis checkout (needs xelatex, bibtex)
parity degree language output ref="latex-reference" dest="build/artifacts":
  #!/usr/bin/env bash
  set -euo pipefail
  degree="{{degree}}"
  language="{{language}}"
  output="{{output}}"
  case "$language" in
    chinese) lang=zh; tex=main.tex ;;
    english) lang=en; tex=main-en.tex ;;
    *) echo "unsupported language: $language" >&2; exit 2 ;;
  esac
  case "$output" in
    electronic) twoside=false ;;
    print) twoside=true ;;
    *) echo "unsupported output: $output" >&2; exit 2 ;;
  esac

  case="$degree-$language-$output"
  ref=$(realpath "{{ref}}")
  out=$(realpath -m "{{dest}}/$case")
  work="$PWD/build/visual-work/$case"
  mkdir -p "$work" "$out"
  header="\\PassOptionsToClass{degree=$degree,degree-type=academic,language=$language,thesis-type=thesis,style-override=none,fontset=fandol}{thuthesis}\\def\\CompareOutput{$output}"

  (cd "$ref" && xelatex -halt-on-error -interaction=batchmode thuthesis.ins)
  for fixture in full focused; do
    if [[ "$fixture" == full ]]; then
      tex_src="$PWD/tests/visual/$tex"; typ_src="contrib/latex-parity/main.typ"
    else
      tex_src="$PWD/tests/visual/cases.tex"; typ_src="tests/visual/cases.typ"
    fi
    for i in 1 2 3; do
      (cd "$ref" && xelatex -halt-on-error -interaction=batchmode -file-line-error \
        -output-directory="$work" -jobname="$case-$fixture" "$header\\input{$tex_src}")
      if [[ "$i" == 1 && "$fixture" == full ]]; then
        (cd "$work" && BIBINPUTS="$ref:" BSTINPUTS="$ref:" bibtex "$case-$fixture")
      fi
    done
    mkdir -p "$out/$fixture"
    cp "$work/$case-$fixture.pdf" "$out/$fixture/latex.pdf"
    typst compile --root . {{font-path}} \
      --input "lang=$lang" --input "degree=$degree" \
      --input degree-type=academic --input "twoside=$twoside" \
      "$typ_src" "$out/$fixture/typst.pdf"
  done

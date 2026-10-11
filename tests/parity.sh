#!/usr/bin/env bash
set -euo pipefail

previous=false
if [[ ${1:-} == --previous ]]; then
	previous=true
	shift
fi
if [[ $# -lt 3 || $# -gt 5 || ($previous == true && $# -lt 4) ]]; then
	echo "usage: $0 [--previous] degree language output [reference] [destination]" >&2
	exit 2
fi

degree=$1
language=$2
output=$3
reference=${4:-latex-reference}
destination=${5:-build/artifacts}

case "$degree" in
	bachelor | master | doctor | postdoc) ;;
	*)
		echo "unsupported degree: $degree" >&2
		exit 2
		;;
esac
case "$language" in
	chinese)
		tex=main
		;;
	english)
		tex=main-en
		;;
	*)
		echo "unsupported language: $language" >&2
		exit 2
		;;
esac
case "$output" in
	electronic | print) ;;
	*)
		echo "unsupported output: $output" >&2
		exit 2
		;;
esac

root=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd)
reference=$(cd -- "$reference" && pwd)
mkdir -p "$destination"
destination=$(cd -- "$destination" && pwd)
case_name="$degree-$language-$output"
header="\\PassOptionsToClass{degree=$degree,degree-type=academic,language=$language,thesis-type=thesis,style-override=none,fontset=fandol}{thuthesis}\\def\\CompareOutput{$output}"

cd "$root"
if "$previous"; then
	reference_label="Parent $(git -C "$reference" rev-parse --short HEAD)"
	current_label="Typst $(git rev-parse --short HEAD)"
else
	reference_label=XeLaTeX
	current_label=Typst
	(cd "$reference" && xelatex -halt-on-error -interaction=batchmode thuthesis.ins)
fi

compile_typst() {
	local tree=$1 source=$2 pdf=$3
	typst compile --root "$tree" --input degree-type=academic --input "degree=$degree" \
		--input "language=$language" --input "output=$output" "$tree/$source" "$pdf"
}

for fixture in full focused; do
	out="$destination/$case_name/$fixture"
	mkdir -p "$out"
	if [[ "$fixture" == full ]]; then
		tex_source="tests/$tex.tex"
		typ_source=template/thesis.typ
	else
		tex_source=tests/cases.tex
		typ_source=tests/cases.typ
	fi
	compile_typst "$root" "$typ_source" "$out/typst.pdf"
	if "$previous"; then
		previous_source=$typ_source
		if [[ $fixture == full && ! -f "$reference/$previous_source" ]]; then
			# Older releases declare a different example entrypoint.
			previous_source=$(cd "$reference" && python3 -c '
import tomllib
from pathlib import Path
template = tomllib.loads(Path("typst.toml").read_text())["template"]
print(Path(template["path"]) / template["entrypoint"])
')
		fi
		reference_pdf="$out/previous.pdf"
		if [[ $fixture == focused && ! -f "$reference/$previous_source" ]]; then
			# A newly added fixture has only current pages to show.
			reference_pdf=-
		else
			compile_typst "$reference" "$previous_source" "$reference_pdf"
		fi
	else
		(cd "$reference" && BIBINPUTS="$PWD:" BSTINPUTS="$PWD:" \
			latexmk -norc -xelatex -quiet -halt-on-error \
			-outdir="$out" -jobname=latex -usepretex="$header" "$root/$tex_source")
		reference_pdf="$out/latex.pdf"
	fi
	python3 tests/overlay.py "$reference_pdf" "$out/typst.pdf" "$out/overlay.pdf" \
		"$reference_label" "$current_label"
done

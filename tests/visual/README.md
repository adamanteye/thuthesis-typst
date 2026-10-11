# Visual fixtures

`main.tex` and `main-en.tex` mirror the complete document in
`contrib/latex-parity/main.typ`. With XeLaTeX and BibTeX installed, compile
against the same ThuThesis revision as CI:

```sh
git clone https://github.com/tuna/thuthesis.git latex-reference
git -C latex-reference checkout b50ce596c248964fe04f317a8fe9b1a0f6b34174
bash scripts/fonts.sh fonts
just parity bachelor chinese electronic   # ref defaults to latex-reference/
```

`cases.tex` and `cases.typ` focus on body text, headers, numbering, figures,
tables, equations, and appendices. Each case produces only original PDFs:
`build/artifacts/<degree>-<language>-<output>/{full,focused}/{latex,typst}.pdf`.
CI combines all 16 cases into the `layout-parity-review` download. Compiler
output stays in Actions; local LaTeX logs are under `build/visual-work/`.

The configuration mapping is explicit:

| Workflow value | ThuThesis | TnTT |
| --- | --- | --- |
| `chinese` | `language=chinese` | `lang=zh` |
| `english` | `language=english` | `lang=en` |
| `electronic` | `output=electronic` | `twoside=false` |
| `print` | `output=print` | `twoside=true` |

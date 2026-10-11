# Tests

The Tests workflow renders both the full thesis and the focused fixture with
the compiler and fonts pinned by `flake.lock`.

| Event | Red layer | Green layer |
| --- | --- | --- |
| PR opened, reopened or updated | PR head's first parent (`HEAD^1`) | PR head |
| Push to `main` or `master`, or manual run | Pinned ThuThesis built with XeLaTeX | Current Typst checkout |

Download `tests-review` from the workflow summary. Each degree/language/output
directory contains `full/overlay.pdf` and `focused/overlay.pdf` alongside the
original PDFs. Black ink shows overlap. Each page lists both original page
numbers. Pages are matched by text and running titles where possible. A dash
marks a page present on only one side.

To reproduce the PR comparison locally:

```sh
git worktree add --detach ../layout-parent HEAD^1
nix develop --no-update-lock-file --command bash tests/parity.sh --previous master chinese electronic ../layout-parent build/pr-review
git worktree remove ../layout-parent
```

To reproduce the main branch comparison:

```sh
git clone https://github.com/tuna/thuthesis.git latex-reference
git -C latex-reference checkout b50ce596c248964fe04f317a8fe9b1a0f6b34174
nix develop --no-update-lock-file --command bash tests/parity.sh master chinese electronic
```

The arguments are degree (`bachelor`, `master`, `doctor`, `postdoc`), language
(`chinese`, `english`), and output (`electronic`, `print`). Optional fourth and
fifth arguments select the reference checkout and artifact destination.
Both engines use the open fonts from the Nix TeX Live environment.

| Workflow value | ThuThesis | TnTT |
| --- | --- | --- |
| `chinese` | `language=chinese` | `language=chinese` |
| `english` | `language=english` | `language=english` |
| `electronic` | `output=electronic` | `output=electronic` |
| `print` | `output=print` | `output=print` |

Both fixtures (`template/thesis.typ` and `tests/cases.typ`) use `define-config(...)`.

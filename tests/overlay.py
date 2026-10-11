"""Overlay two thesis PDFs at their original scale, with a legend in the top margin."""

from difflib import SequenceMatcher
from io import BytesIO
from itertools import zip_longest
import sys
from unicodedata import normalize

from PIL import Image, ImageChops
import pymupdf

DPI = 288
SCALE = DPI / 72


def page_text(document):
    pages = []
    for page in document:
        lines = [
            "".join(normalize("NFKC", line).casefold().split())
            for line in page.get_text(sort=True).splitlines()
            if line.strip()
        ]
        # Ignore the footer when matching a page shifted by an insertion.
        if lines and lines[-1].isdecimal():
            lines.pop()
        pages.append((lines[0] if lines else "", "".join(lines)))
    return pages


def page_pairs(reference, current):
    # Anchor identical text first. Within changed runs, use running titles to
    # resynchronize chapters, then pair the remaining pages in reading order.
    left, right = page_text(reference), page_text(current)
    exact = SequenceMatcher(lambda key: not key[1], left, right, autojunk=False)
    for tag, a, b, c, d in exact.get_opcodes():
        if tag == "replace":
            titles = SequenceMatcher(
                None,
                [t for t, _ in left[a:b]],
                [t for t, _ in right[c:d]],
                autojunk=False,
            )
            for _, i, j, k, end in titles.get_opcodes():
                yield from zip_longest(
                    range(a + i, a + j), range(c + k, c + end)
                )
        else:
            yield from zip_longest(range(a, b), range(c, d))


def render(page, size):
    canvas = Image.new("L", size, "white")
    if page is not None:
        pix = page.get_pixmap(dpi=DPI, colorspace=pymupdf.csGRAY, alpha=False)
        canvas.paste(Image.frombytes("L", (pix.width, pix.height), pix.samples))
    return canvas


def overlay(reference, current, output, reference_label, current_label):
    for left, right in page_pairs(reference, current):
        old = reference[left] if left is not None else None
        new = current[right] if right is not None else None
        sizes = [p.rect for p in (old, new) if p is not None]
        page = output.new_page(
            width=max(r.width for r in sizes),
            height=max(r.height for r in sizes),
        )
        pixels = (page.rect * pymupdf.Matrix(SCALE, SCALE)).irect
        size = (pixels.width, pixels.height)
        before = render(old, size)
        after = render(new, size)
        image = Image.merge(
            "RGB", (after, before, ImageChops.darker(before, after))
        )
        stream = BytesIO()
        image.save(stream, format="PNG", compress_level=1)
        # Keep the physical scale even when the two paper sizes differ.
        page.insert_image(
            pymupdf.Rect(0, 0, pixels.width / SCALE, pixels.height / SCALE),
            stream=stream.getvalue(),
        )
        labels = [
            (
                f"{reference_label} p.{left + 1 if old is not None else '-'}",
                (0.7, 0, 0),
            ),
            (
                f"{current_label} p.{right + 1 if new is not None else '-'}",
                (0, 0.45, 0),
            ),
            ("Overlap", (0, 0, 0)),
        ]
        x = 12
        for label, color in labels:
            page.insert_text((x, 12), label, fontsize=8, color=color)
            x += pymupdf.get_text_length(label, fontsize=8) + 12


if __name__ == "__main__":
    ref, head, dest, ref_label, head_label = sys.argv[1:]
    with (
        pymupdf.open(None if ref == "-" else ref) as reference,
        pymupdf.open(head) as current,
        pymupdf.open() as output,
    ):
        overlay(reference, current, output, ref_label, head_label)
        output.save(dest, deflate=True)

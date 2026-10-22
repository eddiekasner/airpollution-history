"""Copy image alt text from an R Markdown deck into its PowerPoint output.

Pandoc writes the image file name as each picture's description in .pptx
files. This script replaces it with the alt text written in the Rmd, so
screen readers (and PDFs exported from PowerPoint or LibreOffice) get real
descriptions.

Usage:
    python3 add-alt-text.py envh111-airpollution-history.Rmd envh111-airpollution-history.pptx
"""

import html
import re
import shutil
import sys
import tempfile
import zipfile


def read_alt_text(rmd_path):
    text = open(rmd_path, encoding="utf-8").read()
    alt = {}
    for desc, path in re.findall(r"!\[([^\]]+)\]\((images/[^)\s]+)\)", text):
        alt[path] = desc.strip()
    return alt


def main(rmd_path, pptx_path):
    alt = read_alt_text(rmd_path)
    done = set()
    tmp = tempfile.NamedTemporaryFile(delete=False, suffix=".pptx").name
    with zipfile.ZipFile(pptx_path) as zin, zipfile.ZipFile(tmp, "w", zipfile.ZIP_DEFLATED) as zout:
        for item in zin.infolist():
            data = zin.read(item.filename)
            if re.match(r"ppt/slides/slide\d+\.xml$", item.filename):
                xml = data.decode("utf-8")

                def swap(m):
                    path = html.unescape(m.group(1))
                    if path in alt:
                        done.add(path)
                        return 'descr="%s"' % html.escape(alt[path], quote=True)
                    return m.group(0)

                xml = re.sub(r'descr="([^"]*)"', swap, xml)
                data = xml.encode("utf-8")
            zout.writestr(item, data)
    shutil.move(tmp, pptx_path)
    missing = sorted(set(alt) - done)
    print("Alt text added for %d of %d images." % (len(done), len(alt)))
    for path in missing:
        print("  Not found in pptx:", path)


if __name__ == "__main__":
    if len(sys.argv) != 3:
        sys.exit(__doc__)
    main(sys.argv[1], sys.argv[2])

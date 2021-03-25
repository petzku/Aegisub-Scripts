#!/usr/bin/env python3

""" Check that files listed in DependencyControl.json match their hashes """

from hashlib import sha1
from logging import info, error
import json

DC_FILE = "DependencyControl.json"


def check_contents(entry, basename):
    for ch in entry['channels'].values():
        for f in ch['files']:
            filename = basename + f['name']
            with open(filename, 'rb') as fo:
                sha1hash = sha1(fo.read()).hexdigest().lower()
            if sha1hash == f['sha1'].lower():
                info(f"{filename} matches hash")
            else:
                error(f"{filename} hash mismatch!")
                error(f"  filesystem: {sha1hash}")
                error(f"  depctrl:    {f['sha1'].lower()}")


with open(DC_FILE) as fo:
    depctrl = json.load(fo)

for ns, macro in depctrl['macros'].items():
    # assume all macros are in `macros/${namespace}.${extension}`
    basename = 'macros/' + ns
    check_contents(macro, basename)

for ns, module in depctrl['modules'].items():
    # assume all modules are in `modules/${namespacepath}.${extension}`
    # i.e. modules/petzku/util.moon
    basename = 'modules/' + ns.replace('.', '/')
    check_contents(module, basename)

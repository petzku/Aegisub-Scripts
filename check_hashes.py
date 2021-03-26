#!/usr/bin/env python3

""" Check that files listed in DependencyControl.json match their hashes """

from hashlib import sha1
from logging import info, error
import json
import sys

DC_FILE = "DependencyControl.json"


def check_contents(entry, basename):
    all_fine = True
    for ch in entry['channels'].values():
        for f in ch['files']:
            filename = basename + f['name']
            with open(filename, 'rb') as fo:
                sha1hash = sha1(fo.read()).hexdigest().lower()
            if sha1hash == f['sha1'].lower():
                info(f"{filename} matches hash")
            else:
                all_fine = False
                error(f"{filename} hash mismatch!")
                error(f"  filesystem: {sha1hash}")
                error(f"  depctrl:    {f['sha1'].lower()}")
    return all_fine


def main():
    with open(DC_FILE) as fo:
        depctrl = json.load(fo)

    macros_fine = True
    for ns, macro in depctrl['macros'].items():
        # assume all macros are in `macros/${namespace}.${extension}`
        basename = 'macros/' + ns
        if not check_contents(macro, basename):
            macros_fine = False
    if macros_fine:
        print("All macros validated successfully!")

    modules_fine = True
    for ns, module in depctrl['modules'].items():
        # assume all modules are in `modules/${namespacepath}.${extension}`
        # i.e. modules/petzku/util.moon
        basename = 'modules/' + ns.replace('.', '/')
        if not check_contents(module, basename):
            modules_fine = False
    if modules_fine:
        print("All modules validated successfully!")

    if not (macros_fine and modules_fine):
        return 1


if __name__ == "__main__":
    sys.exit(main())

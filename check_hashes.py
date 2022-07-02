#!/usr/bin/env python3

""" Check that files listed in DependencyControl.json match their hashes """

from hashlib import sha1
from logging import info, error
import json
import sys

DC_FILE = "DependencyControl.json"


def check_hash(content, hash, filename):
    sha1hash = sha1(content).hexdigest().lower()
    if sha1hash == hash.lower():
        info(f"{filename} matches hash")
        return True
    else:
        error(f"{filename} hash mismatch!")
        error(f"  filesystem: {sha1hash}")
        error(f"  depctrl:    {hash.lower()}")
        return False


def check_version(content: bytes, version, filename):
    verline = [line for line in str(content, 'utf-8').split("\n") if "version" in line][0]
    filever = verline.replace(":", "=").split("=")[1].strip().strip("'\",")
    if filever == version:
        info(f"{filename} version matches")
        return True
    else:
        error(f"{filename} version mismatch!")
        error(f"  filesystem: {filever}")
        error(f"  depctrl:    {version}")
        return False


def check_contents(entry, basename):
    all_fine = True
    for ch in entry['channels'].values():
        for f in ch['files']:
            filename = basename + f['name']
            with open(filename, 'rb') as fo:
                content = fo.read()
            hash_good = check_hash(content, f['sha1'], filename)
            version_good = check_version(content, ch['version'], filename)
            if not (hash_good and version_good):
                all_fine = False
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

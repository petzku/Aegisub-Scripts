#!/usr/bin/env python3

""" Check that files listed in DependencyControl.json match their hashes """

from hashlib import sha1
from logging import info, error
import json
import sys

DC_FILE = "DependencyControl.json"


def get_version(lines):
    version_line = [line for line in lines if "version" in line][0]
    return version_line.replace(":", "=").split("=")[1].strip().strip("'\",")


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


def check_version(lines, version, filename):
    if not lines:
        return True
    file_ver = get_version(lines)
    if file_ver == version:
        info(f"{filename} version matches")
        return True
    else:
        error(f"{filename} version mismatch!")
        error(f"  filesystem: {file_ver}")
        error(f"  depctrl:    {version}")
        return False


def check_changelog(lines, changelog, filename):
    if not lines:
        return True
    file_ver = get_version(lines)
    latest_log = max(changelog.keys())
    if file_ver == latest_log:
        info(f"{filename} changelog up-to-date")
        return True
    elif file_ver > latest_log:
        error(f"{filename} version newer than changelog!")
        error(f"  filesystem: {file_ver}")
        error(f"  depctrl:    {latest_log}")
        return False
    else:
        error(f"{filename} version older than changelog!")
        error(f"  filesystem: {file_ver}")
        error(f"  depctrl:    {latest_log}")
        return False


def check_contents(entry, basename):
    all_fine = True
    for ch in entry['channels'].values():
        for f in ch['files']:
            filename = basename + f['name']
            with open(filename, 'rb') as fo:
                content = fo.read()
                try:
                    content_lines = content.decode('utf-8').replace("\r", "").split("\n")
                except UnicodeDecodeError:
                    content_lines = None
            hash_good = check_hash(content, f['sha1'], filename)
            version_good = check_version(content_lines, ch['version'], filename)
            changelog_good = check_changelog(content_lines, entry['changelog'], filename)
            if not (hash_good and version_good and changelog_good):
                all_fine = False
    return all_fine


def main():
    with open(DC_FILE) as fo:
        depctrl = json.load(fo)

    macros_fine = True
    for ns, macro in depctrl['macros'].items():
        # assume all macros are in `macros/${namespace}.${extension}`
        basename = "macros/" + ns
        if not check_contents(macro, basename):
            macros_fine = False
    if macros_fine:
        print("All macros validated successfully!")

    modules_fine = True
    for ns, module in depctrl['modules'].items():
        # assume all modules are in `modules/${namespacepath}.${extension}`
        # i.e. modules/petzku/util.moon
        basename = "modules/" + ns.replace(".", "/")
        if not check_contents(module, basename):
            modules_fine = False
    if modules_fine:
        print("All modules validated successfully!")

    if not (macros_fine and modules_fine):
        return 1


if __name__ == "__main__":
    sys.exit(main())

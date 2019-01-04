#!/usr/bin/env python
#

import glob
import os
import re
import sys

KEY_REGEX = r'([\'\"])version\1:\s*([\'\"])1[0-2]\.0(?:\.[0-9]+){3,3}\2'
VERSION_REGEX = r'(1[0-2]\.0)\.([0-9]+)\.([0-9]+)\.([0-9]+)'


def integrate(ex, msg):
    if ex.args:
        ex_msg = ex.args[0]

    else:
        ex_msg = ""

    new_msg = msg.format(ex_msg).strip()
    ex.args = (new_msg,)

    return ex

class ManifestHandler:
    debug = None

    key_regex = None
    version_regex = None

    manifests = None

    def __init__(self, debug=False):
        assert os.path.isdir('.git'), "You cannot run this script outside of a GIT repository."

        self.debug = debug

        self.key_regex = re.compile(KEY_REGEX)
        self.version_regex = re.compile(VERSION_REGEX)

        self.manifests = []

    def _get_key_match(self, data):
        key_match = self.key_regex.search(data)
        assert key_match, "Cannot find a supported 'version' key."

        return key_match

    def _get_version_match(self, key):
        version_match = self.version_regex.search(key)
        assert version_match, "Cannot find a supported 'version'."

        return version_match

    def _get_version(self, data):
        key_match = self._get_key_match(data)
        version_match = self._get_version_match(key_match.group())

        odoo = version_match.group(1)
        major = version_match.group(2)
        minor = version_match.group(3)
        patch = version_match.group(4)

        return odoo, major, minor, patch

    def _replace_version(self, data, odoo, major, minor, patch):
        key_match = self._get_key_match(data)

        new_version = "{}.{}.{}.{}".format(odoo, major, minor, patch)
        new_key = self.version_regex.sub(new_version, key_match.group())
        new_data = self.key_regex.sub(new_key, data)

        return new_data

    def find_manifests(self):
        self.manifests = glob.glob('*/__manifest__.py')

    def increment_patch(self):
        for manifest in self.manifests:
            try:
                with open(manifest, 'r+') as file:
                    data = file.read()
                    version = self._get_version(data)
                    new_patch = str(int(version[3]) + 1)

                    if self.debug:
                        old_version = "{}.{}.{}.{}".format(version[0], version[1], version[2], version[3])
                        new_version = "{}.{}.{}.{}".format(version[0], version[1], version[2], new_patch)

                        print("Rewriting version from \'{}\' to \'{}\' in file \"{}\"...".format(old_version, new_version, manifest))

                    new_data = self._replace_version(data, version[0], version[1], version[2], new_patch)

                    file.seek(0)
                    file.write(new_data)

            except Exception as ex:
                raise integrate(ex, "There was an error handling file \"{}\". {{}}".format(manifest))


if __name__ == '__main__':
    handler = ManifestHandler(True)

    try:
        handler.find_manifests()
        handler.increment_patch()

    except Exception as ex:
        raise integrate(ex, "{}\nPlease, consider deleting changes in this repository.")

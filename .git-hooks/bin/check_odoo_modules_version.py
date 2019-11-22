#!/usr/bin/env python3
#

import os
import re
import sys

from argparse import ArgumentParser

try:
    from setuptools_odoo.git_postversion import STRATEGY_99_DEVN, get_git_postversion

except ModuleNotFoundError:
    print("Did you install 'setuptools_odoo' in your active Python environment?")

    sys.exit(1)

DEV_REGEX = re.compile(r'\.99\.dev\d+')


class RepositoryType:
    NO_MODULE = -1
    ROOT_MODULE = 0
    SINGLE_MODULE = 1
    MULTI_MODULE = 2


def guess_odoo_modules_repository_type(directory):
    files = os.listdir(directory)

    if 'setup' in files:
        setup_dir_path = os.path.join(directory, 'setup')

        if os.path.isdir(setup_dir_path):
            return RepositoryType.MULTI_MODULE

    elif 'setup.py' in files:
        setup_file_path = os.path.join(directory, 'setup.py')

        if os.path.isfile(setup_file_path):
            module_path = os.path.join(directory, 'odoo/addons')

            if os.path.exists(module_path):
                return RepositoryType.SINGLE_MODULE

    elif '__manifest__.py' in files:
        manifest_file_path = os.path.join(directory, '__manifest__.py')

        if os.path.isfile(manifest_file_path):
            return RepositoryType.ROOT_MODULE

    return RepositoryType.NO_MODULE


def check_module_version(directory, raise_if_dev_version=True):
    version = get_git_postversion(directory, STRATEGY_99_DEVN)

    if DEV_REGEX.search(version):
        module_name = os.path.basename(directory)
        error_message = "The version of the \"{}\" module is \"{}\".".format(module_name, version)

        if raise_if_dev_version:
            raise ValueError(error_message)

        else:
            print(error_message)


def get_module_directories(directory):
    modules = []
    files = os.listdir(directory)

    for subdirectory in filter(lambda f: os.path.isdir(f), files):
        module = os.path.join(directory, subdirectory)
        manifest = os.path.join(module, '__manifest__.py')

        if os.path.exists(manifest):
            modules.append(module)

    return modules


def check_modules_version(directory, raise_if_dev_version=True):
    repository_type = guess_odoo_modules_repository_type(directory)

    if repository_type == RepositoryType.NO_MODULE:
        raise ModuleNotFoundError("The directory \"{}\" does not contain a valid Odoo module.".format(directory))

    if repository_type == RepositoryType.ROOT_MODULE:
        check_module_version(directory, raise_if_dev_version=raise_if_dev_version)

    elif repository_type == RepositoryType.SINGLE_MODULE:
        module_path = os.path.join(directory, 'odoo/addons')
        modules = get_module_directories(module_path)

        for module in modules:
            check_module_version(module, raise_if_dev_version=raise_if_dev_version)

    elif repository_type == RepositoryType.MULTI_MODULE:
        modules = get_module_directories(directory)

        for module in modules:
            check_module_version(module, raise_if_dev_version=raise_if_dev_version)


if __name__ == '__main__':
    parser = ArgumentParser(description="Check if the version of the Odoo modules will be DEV.")
    parser.add_argument('directory', help="The root GIT directory for Odoo modules to check.")

    args = parser.parse_args()

    try:
        check_modules_version(args.directory, raise_if_dev_version=False)

    except ModuleNotFoundError as exc:
        sys.exit(0)

    except ValueError as exc:
        print(exc)

        sys.exit(0)

    else:
        sys.exit(0)

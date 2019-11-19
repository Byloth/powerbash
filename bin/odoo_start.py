#!/usr/bin/env python3
#

from argparse import ArgumentParser
# import subprocess

# from lib import tty
from lib.odoo import OdooInstance
from lib.docker.core import DockerImage

#
# https://docs.python.org/3/library/argparse.html
#

class OdooStartCommand:
    _args = None
    _odoo = None

    @classmethod
    def get_parser(cls):
        parser = ArgumentParser(description="Process some integers.")
        parser.add_argument('integers', metavar='N', type=int, nargs='+',
                            help="an integer for the accumulator")
        parser.add_argument('--sum', dest='accumulate', action='store_const',
                            const=sum, default=max,
                            help="sum the integers (default: find the max)")

        return parser

    def __init__(self):
        self._odoo = OdooInstance()

        image = DockerImage('debian', 'stretch')
        image.is_available


        # parser = self.get_parser()
        # self._args = parser.parse_args()

    def execute(self):
        # tty.clear()

        self._odoo.run()


if __name__ == '__main__':
    odoo_start = OdooStartCommand()
    odoo_start.execute()

import argparse
import subprocess

from libs import tty
from libs.odoo import Odoo

#
# https://docs.python.org/3/library/argparse.html
#

class OdooStart:
    _args = None
    _odoo = None

    @classmethod
    def get_parser(cls):
        parser = argparse.ArgumentParser(description="Process some integers.")
        parser.add_argument('integers', metavar='N', type=int, nargs='+',
                            help="an integer for the accumulator")
        parser.add_argument('--sum', dest='accumulate', action='store_const',
                            const=sum, default=max,
                            help="sum the integers (default: find the max)")

        return parser

    def __init__(self):
        self._odoo = Odoo()
    #     parser = self.get_parser()

    #     self._args = parser.parse_args()

    def execute(self):
        tty.clear()

        self._odoo.start()


if __name__ == '__main__':
    odoo_start = OdooStart()
    odoo_start.execute()

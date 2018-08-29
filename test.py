import argparse

#
# https://docs.python.org/3/library/argparse.html
#

class Test:
    _args = None

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
        parser = self.get_parser()

        self._args = parser.parse_args()

    def execute(self):
        print(self._args.accumulate(self._args.integers))


if __name__ == '__main__':
    test = Test()

    test.execute()

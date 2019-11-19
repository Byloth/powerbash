import subprocess

from ..core import Cli


class DockerImage(Cli):
    _name = None
    _version = None

    def __init__(self, name, version='latest'):
        self._name = name
        self._version = version

    def __str__(self):
        return "{}:{}".format(self._name, self._version)

    @property
    def is_available(self):
        response = self.run('ls', '-lsrt')

        print()
        for line in response:
            print(line)
        print()

    @property
    def is_latest(self):
        raise NotImplementedError

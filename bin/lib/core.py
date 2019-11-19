import subprocess


class Cli:
    @staticmethod
    def run(*args):
        pipe = subprocess.Popen(args, shell=True, stdout=subprocess.PIPE, stderr=subprocess.STDOUT)
        lines = [str(line, encoding='utf-8').strip() for line in pipe.stdout.readlines()]

        result = pipe.wait()
        if result != 0:
            raise CliError(*lines)

        return lines


class CliError(RuntimeError):
    _lines = None

    def __init__(self, *lines):
        self._lines = lines

    def __str__(self):
        return "\n".join(self._lines)

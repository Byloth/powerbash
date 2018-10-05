import abc


class ConfigurationLoader:
    __metaclass__ = abc.ABCMeta

    _filename = None

    def __init__(self, filename):
        self._filename = filename

    def _sanitize_line(self, line):
        line = line.replace("\n", "")
        comment = line.find("#")

        if comment > -1:
            line = line[:comment]

        return line.strip()

    def _parse_line(self, line):
        couple = line.split("=")

        return couple[0].strip(), couple[1].strip()

    def _get_lines(self, config_file):
        for line in config_file:
            line = self._sanitize_line(line)

            if line:
                yield self._parse_line(line)

    @abc.abstractmethod
    def _store_configuration(self, key, value):
        pass

    def load(self):
        #
        # FIXME: What happen if configs file does not exists?!
        #
        with open(self._filename) as config_file:
            lines = self._get_lines(config_file)

            for key, value in lines:
                self._store_configuration(key, value)

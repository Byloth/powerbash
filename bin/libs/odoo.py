import logging
import os

from .docker import Docker

DEFAULT_CONFIG_FILE = 'odoo.conf'

_logger = logging.getLogger(__name__)


class Odoo:
    _docker = None

    _config_file = None
    _configs = None

    def __init__(self):
        if 'ODOO_CONFIG_FILE' in os.environ:
            self._config_file = os.environ['ODOO_CONFIG_FILE']

        else:
            self._config_file = DEFAULT_CONFIG_FILE

        self._docker = Docker()

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

    def _get_configs(self, config_file):
        configs = {}
        lines = self._get_lines(config_file)

        for key, value in lines:
            if key in configs:
                _logger.warning("Property \"%s\" already exists in configs' dictionary!" % key)

            configs[key] = value

        return configs


    def _load_configurations(self):
        with open(self._config_file) as config_file:
            self._configs = self._get_configs(config_file)

        print(self._configs)

    def _load_defaults(self):
        pass

    def start(self, **kwargs):
        self._load_configurations()
        # loadDefaults
        #  ...
        # checkConfigurations
        # (exportConfigurations)?

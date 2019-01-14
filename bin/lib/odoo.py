import logging
import os
import yaml

from .docker import DockerContainer

DEFAULT_CONFIG_FILE = 'odoo.conf.yml'

_logger = logging.getLogger(__name__)
_logger.setLevel(logging.DEBUG)


class OdooInstance:
    admin_passwd = 'admin'
    port = 8069

    pghost = 'localhost'
    pgport = 5432
    pguser = 'postgres'
    pgpassword = None

    _container = None
    _config_file = None

    def __init__(self):
        if 'ODOO_CONFIG_FILE' in os.environ:
            self._config_file = os.environ['ODOO_CONFIG_FILE']

        #
        # TODO: Search ".odoo.conf" under user's home directory...
        #

        else:
            self._config_file = DEFAULT_CONFIG_FILE

        self._container = DockerContainer()

    def start(self, **kwargs):
        with open(self._config_file) as file:
            data = file.read()
            
            _logger.info(yaml.load(data))
        # self._load_configurations()
        # self._load_defaults()
        #  ...
        # checkConfigurations
        # (exportConfigurations)?

    def store_configuration(self, key, value):
        if key in ['container', 'name']:
            self.NAME = value

        elif key in ['image']:
            self.IMAGE = value

        elif key in ['version']:
            self.VERSION = value

        elif key in ['port']:
            self.PORTS.append(value)

        elif key in ['env', 'variable']:
            self.ENV_VARS.append(value)

        elif key in ['mount', 'volume']:
            self.VOLUMES.append(value)

        elif key in ['admin_pass', 'admin_passwd', 'admin_password']:
            self.admin_passwd = value

        elif key in ['pghost']:
            self.pghost = value

        elif key in ['pgport']:
            self.pgport = value

        elif key in ['pguser', 'pgusername']:
            self.pguser = value

        elif key in ['pgpass', 'pgpasswd', 'pgpassword']:
            self.pgpassword = value

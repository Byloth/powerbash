import logging
import os

from .docker import Docker, DockerConfiguration
from .postgresql import PostgreSqlConfiguration

DEFAULT_CONFIG_FILE = 'odoo.conf'

_logger = logging.getLogger(__name__)
_logger.setLevel(logging.DEBUG)

class OdooDefault(DockerConfiguration, PostgreSqlConfiguration):
    PORT = 8069
    PGHOST = DockerConfiguration.HOST_IP
    PGPORT = PostgreSqlConfiguration.PORT
    PGUSER = PostgreSqlConfiguration.USER
    PGPASSWORD = PostgreSqlConfiguration.PASSWORD
    ADMIN_PASSWD = "admin00"

    def __init__(self, filename):
        super().__init__(filename)

    def _store_configuration(self, key, value):
        if key in ['admin_pass', 'admin_passwd', 'admin_password']:
            self.ADMIN_PASSWD = value 

        else:
            super()._store_configuration(key, value)


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

    def start(self, **kwargs):
        self._load_configurations()
        self._load_defaults()
        #  ...
        # checkConfigurations
        # (exportConfigurations)?

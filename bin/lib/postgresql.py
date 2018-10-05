from .docker import DockerConfiguration


class PostgreSqlConfiguration(DockerConfiguration):
    HOST = 'localhost'
    PORT = 5432
    USER = 'root'
    PASSWORD = ''

    def _store_configuration(self, key, value):
        if key in ['pghost']:
            self.HOST = value
        
        elif key in ['pgport']:
            self.PORT = value

        elif key in ['pguser']:
            self.USER = value

        elif key in ['pgpass', 'pgpassword']:
            self.PASSWORD = value

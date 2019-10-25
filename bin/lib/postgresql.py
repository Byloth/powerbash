class PostgreSql:
    pghost = 'localhost'
    pgport = 5432
    pguser = 'postgres'
    pgpassword = None

    def store_configuration(self, key, value):
        if key in ['pghost']:
            self.pghost = value
        
        elif key in ['pgport']:
            self.pgport = value

        elif key in ['pguser', 'pgusername']:
            self.pguser = value

        elif key in ['pgpass', 'pgpassword']:
            self.pgpassword = value

        else:
            super().store_configuration(key, value)

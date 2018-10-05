from .io import ConfigurationLoader


class DockerConfiguration(ConfigurationLoader):
    HOST_IP = '10.0.75.1'

    CONTAINER_NAME = None
    IMAGE_NAME = None
    IMAGE_VERSION = None

    PORTS = None
    ENV_VARS = None
    VOLUMES = None

    def __init__(self, filename):
        self.PORT = []
        self.ENV_VARS = []
        self.VOLUMES = [] 

    def _store_configuration(self, key, value):
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



class Docker:
    def __init__(self):
        # isDockerRunning
        pass

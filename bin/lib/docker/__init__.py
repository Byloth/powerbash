import platform

HOST_ADDRESS = None


class DockerContainer:
    _ports = None
    _envs = None
    _volumes = None

    name = None
    image = None
    version = None

    is_interactive = None
    is_volatile = None

    def __init__(self):
        #
        # TODO: Is Docker deamon running?
        #
        self._ports = {}
        self._envs = {}
        self._volumes = {}


    def define_environment_variable(self, name, value):
        pass

    def map_port(self, guest_port, host_port=None):
        if not host_port:
            host_port = guest_port

        self._ports[guest_port] = host_port

    def mount_volume(self, volume_or_path, container_path, is_readonly=False):
        pass


if platform.system() in ['Darwin', 'Windows']:
    HOST_ADDRESS = 'host.docker.internal'

else:
    HOST_ADDRESS = 'localhost'

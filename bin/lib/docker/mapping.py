from .errors import DockerError

class DockerMap:
    internal = None
    external = None

    def __init__(self, internal=None, external=None):
        if not internal:
            raise DockerError("Missing 'internal' mapping argument.")

        if not external:
            external = internal

        self.internal = internal
        self.external = external


class VolumeType:
    DIRECTORY_TYPE = 'directory'
    VOLUME_TYPE = 'volume'


class PortMap(DockerMap):
    pass


class VolumeMap(DockerMap):
    is_readonly = None

    def __init__(self, internal=None, external=None, is_readonly=False):
        super().__init__(internal=internal, external=external)

        self.is_readonly = is_readonly

    @property
    def type(self):
        #
        # TODO: Guess what's the time of the volume...
        #
        pass

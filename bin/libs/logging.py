import logging
import os

from . import tty
from .tty import TextColor

LOG_FORMAT = '[%(asctime)s] %(levelname)s (%(name)s): %(message)s'
LOG_DATE_FORMAT= '%d/%m/%Y %H:%M:%S'
LOG_LEVEL_COLORS = {
    50: TextColor.RED,
    40: TextColor.DARK_RED,
    30: TextColor.DARK_YELLOW,
    20: TextColor.DARK_GREEN,
    10: TextColor.LIGHT_BLUE,
    0: TextColor.GRAY,
}


class ColoredFormatter(logging.Formatter):
    def __init__(self, fmt=None, datefmt=None):
        if not fmt:
            fmt = LOG_FORMAT

        if not datefmt:
            datefmt = LOG_DATE_FORMAT

        logging.Formatter.__init__(self, fmt, datefmt)

    def format(self, record):
        level_color = LOG_LEVEL_COLORS.get(record.levelno)
        record.levelname = tty.pretty(record.levelname, text_color=level_color)

        return logging.Formatter.format(self, record)


class ColoredLogger(logging.Logger):
    def __init__(self, name, level=None):
        if not level:
            level = logging.DEBUG

        logging.Logger.__init__(self, name, level)

        console = logging.StreamHandler()
        formatter = ColoredFormatter()

        console.setFormatter(formatter)

        self.addHandler(console)

logging.setLoggerClass(ColoredLogger)

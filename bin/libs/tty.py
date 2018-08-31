import os


class TextFormat:
    DEFAULT = '0'
    BOLD = '1'
    DIM = '2'
    UNDERLINE = '3'
    BLINK = '5'
    REVERSE = '7'
    HIDDEN = '8'


class TextColor:
    DEFAULT = '39'
    BLACK = '30'
    DARK_RED = '31'
    DARK_GREEN = '32'
    DARK_YELLOW = '33'
    BLUE = '34'
    DARK_MAGENTA = '35'
    DARK_CYAN = '36'
    LIGHT_GRAY = '37'
    GRAY = '90'
    RED = '91'
    GREEN = '92'
    YELLOW = '93'
    LIGHT_BLUE = '94'
    MAGENTA = '95'
    CYAN = '96'
    WHITE = '97'


class BackgroundColor:
    DEFAULT = '49'
    BLACK = '40'
    DARK_RED = '41'
    DARK_GREEN = '42'
    DARK_YELLOW = '43'
    BLUE = '44'
    DARK_MAGENTA = '45'
    DARK_CYAN = '46'
    LIGHT_GRAY = '47'
    GRAY = '100'
    RED = '101'
    GREEN = '102'
    YELLOW = '103'
    LIGHT_BLUE = '104'
    MAGENTA = '105'
    CYAN = '106'
    WHITE = '107'


def clear():
    os.system('cls' if os.name == 'nt' else 'clear')
    
def pretty(text, text_color=None, text_format=None, background_color=None):
    args = []

    if text_color:
        args.append(text_color)
    
    if text_format:
        args.append(text_format)
    
    if background_color:
        args.append(background_color)

    attrs = ";".join(args)

    return "\\e[{}m{}\\e[0m".format(attrs, text)

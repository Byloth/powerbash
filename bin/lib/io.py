def read_configs_from_file(filename):
    def sanitize_line(line):
        line = line.replace("\n", "")
        comment = line.find("#")

        if comment > -1:
            line = line[:comment]

        return line.strip()

    def parse_line(line):
        couple = line.split("=", 1)

        return couple[0].strip(), couple[1].strip()

    def generate_lines(config_file):
        for line in config_file:
            line = sanitize_line(line)

            if line:
                yield parse_line(line)
    #
    # FIXME: What happen if configs file does not exists?!
    #
    with open(filename) as config_file:
        lines = generate_lines(config_file)

    return lines

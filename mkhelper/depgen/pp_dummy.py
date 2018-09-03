class DummyPreprocessor:
    included_files = set()

    def __init__(self, stream):
        self.close = stream.close
        self.readline = stream.readline
        self.name = stream.name

    def print_debug(self, stream):
        stream.writelines([
            '# Dummy preprocessor:\n'
            '#   Input file: ', self.name])

class Benchmark:
    """Represents an individual benchmark program"""

    def __init__(self, suite, name, size):
        self.suite = suite
        self.name = name
        self.size = size

    def display_name(self):
        return self.name


class NPB(Benchmark):
    """Represents a benchmark program from the NAS Parallel Benchmark suite"""

    def __init__(self, name, size, version=''):
        Benchmark.__init__(self, 'npb', name, size)
        self.version = version

    def display_name(self):
        if self.version == '':
            return self.name
        else:
            return self.name + '_' + self.version

    def build_command(self, build_dir=''):
        command = ['make', self.name, 'CLASS=' + self.size, 'VERSION=' + self.version]

        if build_dir != '':
            command.append('-C')
            command.append(build_dir)

        return command

    def binary_name(self):
        return self.name.lower() + '.' + self.size + '.x'

    @staticmethod
    def run_successful():
        success = True
        with open("result", mode="r") as benchmark_output_file:
            benchmark_output = benchmark_output_file.read()
            benchmark_output = "".join(benchmark_output.split())

            if "Verification=SUCCESSFUL" not in benchmark_output:
                success = False

        return success

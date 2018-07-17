import subprocess


class Benchmark:
    """Represents an individual benchmark program"""

    def __init__(self, suite, name, root_dir):
        self.suite = suite
        self.name = name
        self.root_dir = root_dir

    def display_name(self):
        return self.name


class NPB(Benchmark):
    """Represents a benchmark program from the NAS Parallel Benchmark suite"""

    def __init__(self, name, size, root_dir, version=''):
        Benchmark.__init__(self, 'npb', name, root_dir)
        self.version = version
        self.size = size

    def display_name(self):
        disp_name = self.name + '.' + self.size

        if self.version != '':
            disp_name += '_' + self.version

        return disp_name

    def build_command(self):
        command = ['make', self.name, 'CLASS=' + self.size, 'VERSION=' + self.version, '-C', self.root_dir]

        return command

    def run_command(self):
        return [self.root_dir + "/bin/" + self.name.lower() + "." + self.size + ".x"]

    @staticmethod
    def run_successful():
        success = True
        with open("energy-monitor.out", mode="r") as benchmark_output_file:
            benchmark_output = benchmark_output_file.read()
            benchmark_output = "".join(benchmark_output.split())

            if "Verification=SUCCESSFUL" not in benchmark_output:
                success = False

        return success


class SPEC(Benchmark):
    """Represents a benchmark program from the SPEC OpenMP 2012 benchmark suite"""

    def __init__(self, name, root_dir):
        Benchmark.__init__(self, 'spec', name, root_dir)

    def build_command(self):
        return ['make', '-C', self.root_dir + "/" + self.name]

    def run_command(self):
        return self.root_dir + "/" + self.name + "/run.sh"

    def run_successful(self):
        validate_command = [self.root_dir + "/" + self.name + "/validate.sh"]

        validation_result = subprocess.call(validate_command)
        return validation_result == 0

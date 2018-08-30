import os
import subprocess

from common.basedirectory import *


class Benchmark:
    """Represents an individual benchmark program"""

    def __init__(self, suite, name, root_dir):
        self.suite = suite
        self.name = name
        self.root_dir = root_dir

    def display_name(self):
        return self.name


class Parboil(Benchmark):
    """Represents a benchmark form the Parboil bencharmk suite"""

    def __init__(self, name, size, root_dir):
        Benchmark.__init__(self, 'parboil', name, root_dir)
        self.size = size

    def build_command(self):
        os.chdir(parboil_dir)
        return [f"{self.root_dir}/parboil", "compile", self.name, "omp_base"]
   
    def clean_command(self):
        os.chdir(parboil_dir)
        return [f"{self.root_dir}/parboil", "clean", self.name]

    def run_command(self):
        os.chdir(parboil_dir)
        return f"{self.root_dir}/parboil run {self.name} omp_base {self.size}"

    def run_successful(self, output_file):
        success = True
        with open(output_file, mode="r") as benchmark_output_file:
            benchmark_output = benchmark_output_file.read()
            benchmark_output = "".join(benchmark_output.split())

            if "Pass" not in benchmark_output:
                success = False

        return success


class Rodinia(Benchmark):
    """Represents a benchmark form the Rodinia bencharmk suite"""

    def __init__(self, name, root_dir):
        Benchmark.__init__(self, 'rodinia', name, root_dir)

    def build_command(self):
        return ["make", "-C", f"{self.root_dir}/{self.name}"]

    def clean_command(self):
        return ["make", "clean", "-C", f"{self.root_dir}/{self.name}"]

    def run_command(self):
        return f"{self.root_dir}/{self.name}/run.sh"

    def run_successful(self, output_file):
        return True # Rodinia doesn't provide validation scripts


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
        return ['make', self.name, 'CLASS=' + self.size, 'VERSION=' + self.version, '-C', self.root_dir]

    def clean_command(self):
        return ['make', 'clean', '-C', f"{self.root_dir}/{self.name}"]

    def run_command(self):
        return f"{self.root_dir}/bin/{self.name.lower()}.{self.size}.x"

    def run_successful(self, output_file):
        success = True
        with open(output_file, mode="r") as benchmark_output_file:
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

    def clean_command(self):
        return ['make', 'clean', '-C', self.root_dir + "/" + self.name]

    def run_command(self):
        return f"{self.root_dir}/{self.name}/run.sh"
        #return self.root_dir + "/" + self.name + "/run.sh"

    def run_successful(self, output_file=''):
        validate_command = [self.root_dir + "/" + self.name + "/validate.sh"]

        validation_result = subprocess.call(validate_command)
        return validation_result == 0

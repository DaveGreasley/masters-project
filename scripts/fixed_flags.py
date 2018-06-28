import os
import time
from pathlib import Path

from subprocess import call, Popen, PIPE

flags = ["-O0", "-O1", "-O2", "-O3"]

environment = "bc"

base_dir = str(Path.home()) + "/masters-project"
build_dir = base_dir + "/benchmarks/NPB3.3-OMP"
energy_monitor = base_dir + "/energy-monitor/energy-monitor"
bin_dir = base_dir + "/benchmarks/NPB3.3-OMP/bin"
results_filename = base_dir + "/results/fix_flags." + environment + "."  + time.strftime("%Y%m%d-%H%M%S") + ".csv"

samples = 3

with open(results_filename, mode="a", buffering=1) as results_file:
    results_file.write("Benchmark, Flags, Energy, Time, Success\n")

    for flag in flags:

        os.environ['COMPILE_FLAGS'] = flag

        call(["make", "suite", "-C", build_dir])

        for benchmark in os.listdir(bin_dir):
            for i in range(0, samples):
                p = Popen([energy_monitor, bin_dir + "/" + benchmark], stdout=PIPE)
                result = p.stdout.read().decode("utf-8")
                energy = int(result.split(",")[0])
                time = float(result.split(",")[1])
                
                success = 'true'
                with open("result", mode="r") as benchmark_output_file:
                    benchmark_output = benchmark_output_file.read()
                    benchmark_output = "".join(benchmark_output.split())

                    if "Verification=SUCCESSFUL" not in benchmark_output:
                        success = 'false'

                output = benchmark + ","
                output += flag + ","
                output += str(energy) + ","
                output += str(time) + "," 
                output += success +"\n"
                results_file.write(output)

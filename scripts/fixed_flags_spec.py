#!/usr/bin/env python

import os
import time
from os.path import expanduser

from subprocess import call, Popen, PIPE

flags = ["-O1", "-O2", "-O3"]

environment = "bc"

base_dir = expanduser("~") + "/masters-project"
energy_monitor = base_dir + "/energy-monitor/energy-monitor"
energy_monitor_output_file = "energy-monitor.out"
spec_dir = base_dir + "/benchmarks/spec_omp2012"
results_filename = base_dir + "/results/fix_flags." + environment + "."  + time.strftime("%Y%m%d-%H%M%S") + ".csv"

samples = 3

with open(results_filename, mode="a", buffering=1) as results_file:
    results_file.write("Benchmark,Flags,Energy,Time,Success\n")

    for flag in flags:
        os.environ['COMPILE_FLAGS'] = flag

#        for benchmark in os.listdir(spec_dir):
        for benchmark in ['botsalgn','botsspar','bwaves','fma3d','ilbdc','imagick','kdtree','md','nab','smithwa','swim']:
            benchmark_dir = spec_dir + "/" + benchmark

            if os.path.isdir(benchmark_dir):
                os.chdir(benchmark_dir)

                call(["make"])

                for i in range(0, samples):
                    energy_monitor_command = [energy_monitor,
                                              "--output", energy_monitor_output_file,
                                              "--command", f"\"{benchmark_dir}/run.sh\""]
                    p = Popen(energy_monitor_command, stdout=PIPE)
                    result = p.stdout.read().decode("utf-8")
                    energy = int(result.split(",")[0])
                    time = float(result.split(",")[1])

                    validate_result = call([f"{benchmark_dir}/validate.sh"])
                    success = validate_result == 0

                    output = benchmark + ","
                    output += flag + ","
                    output += str(energy) + ","
                    output += str(time) + ","
                    output += str(success) + "\n"
                    results_file.write(output)

                call(["make", "clean"])

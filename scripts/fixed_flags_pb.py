#!/usr/bin/env python

import os
import time
import tempfile
from os.path import expanduser

from subprocess import call

from common.basedirectory import *
from common.energyutils import measure

flags = ["-O1", "-O2", "-O3"]

environment = "bc"

energy_monitor = energy_monitor_dir + "/energy-monitor"

samples = 10
energy_monitor_output_file = "energy-monitor.out"
results_filename = results_dir + "/fix_flags." + environment + "."  + time.strftime("%Y%m%d-%H%M%S") + ".csv"

with open(results_filename, mode="a", buffering=1) as results_file:
    results_file.write("Benchmark,Flags,Energy,Time,Success\n")

    for flag in flags:
        os.environ['COMPILE_FLAGS'] = flag

        benchmarks = [('tpacf', 'small'),
                      ('stencil', 'default'),
                      ('lbm', 'long'),
                      ('bfs', '1M'),
                      ('histo', 'medium'),
                      ('mri-gridding', 'smaller')
                     ]

        for benchmark, size in benchmarks:
            benchmark_dir = f"{parboil_dir}/benchmarks/{benchmark}"

            if os.path.isdir(benchmark_dir):
                os.chdir(parboil_dir)
                call(["./parboil", "compile", benchmark, "omp_base"])

                for i in range(0, samples):
                    energy_monitor_command = [energy_monitor,
                                              "--output", energy_monitor_output_file,
                                              "--command", f"{benchmark_dir}/run.sh"]

                    energy, time = measure(energy_monitor_command)

                    success = True
                    with open(energy_monitor_output_file, mode="r") as benchmark_output_file:
                        benchmark_output = benchmark_output_file.read()
                        benchmark_output = "".join(benchmark_output.split())

                        if "Pass" not in benchmark_output:
                            success = False
               
                    output = benchmark + ","
                    output += flag + ","
                    output += str(energy) + ","
                    output += str(time) + ","
                    output += str(success) + "\n"
                    results_file.write(output)

                os.chdir(parboil_dir)
                call(["./parboil", "clean", benchmark])

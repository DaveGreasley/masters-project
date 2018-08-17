#!/usr/bin/env python

import os
import time
from os.path import expanduser

from subprocess import call

from common.basedirectory import *
from common.energyutils import measure

flags = ["-O1", "-O2", "-O3"]

environment = "bc"

bin_dir = npb_dir + "/bin"

energy_monitor = energy_monitor_dir + "/energy-monitor"

samples = 10 
energy_monitor_output_file = "energy-monitor.out"
results_filename = results_dir + "/fix_flags." + environment + "."  + time.strftime("%Y%m%d-%H%M%S") + ".csv"

with open(results_filename, mode="a", buffering=1) as results_file:
    results_file.write("Benchmark,Flags,Energy,Time,Success\n")

    for flag in flags:

        os.environ['COMPILE_FLAGS'] = flag

        call(["make", "suite", "-C", npb_dir])

        for benchmark in os.listdir(bin_dir):
            for i in range(0, samples):
                energy_monitor_command = [energy_monitor, 
                                          "--output", energy_monitor_output_file, 
                                          "--command", f"\"{bin_dir}/{benchmark}\""]

                energy, time = measure(energy_monitor_command)
                
                success = True
                with open(energy_monitor_output_file, mode="r") as benchmark_output_file:
                    benchmark_output = benchmark_output_file.read()
                    benchmark_output = "".join(benchmark_output.split())

                    if "Verification=SUCCESSFUL" not in benchmark_output:
                        success = False

                output = benchmark + ","
                output += flag + ","
                output += str(energy) + ","
                output += str(time) + "," 
                output += str(success) +"\n"
                results_file.write(output)

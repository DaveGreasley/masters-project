#!/usr/bin/env python

import sys
import time
import os
import subprocess
import argparse

from model import NPB
from model import SPEC

debug = False

#base_dir = "/home/dave/Documents/project"
base_dir = "/mnt/storage/home/dg17763/masters-project"
#base_dir = "/home/dave/masters-project/"
results_dir = base_dir + "/results"
npb_dir = base_dir + "/benchmarks/NPB3.3-OMP"
spec_dir = base_dir + "/benchmarks/spec_omp2012"
energy_monitor_dir = base_dir + "/energy-monitor"


energy_monitor = energy_monitor_dir + "/energy-monitor"
results_filename = base_dir + "/results/RIC." + time.strftime("%Y%m%d-%H%M%S") + ".csv"

# This is the number of times the benchmark programs will be run
num_samples = 3

available_benchmarks = [
    NPB('BT', 'C', npb_dir),
    #NPB('BT', 'C', npb_dir, version='VEC'),
    NPB('CG', 'C', npb_dir),
    NPB('EP', 'D', npb_dir),
    NPB('FT', 'C', npb_dir),
    NPB('IS', 'D', npb_dir),
    NPB('LU', 'C', npb_dir),
    #NPB('LU', 'C', npb_dir, version='VEC'),
    NPB('MG', 'D', npb_dir),
    NPB('SP', 'C', npb_dir),
    NPB('UA', 'C', npb_dir),
    SPEC('botsalgn', spec_dir),
    SPEC('botsspar', spec_dir),
    SPEC('bwaves', spec_dir),
    SPEC('fma3d', spec_dir),
    SPEC('ilbdc', spec_dir),
    SPEC('kdtree', spec_dir),
    SPEC('md', spec_dir),
    SPEC('nab', spec_dir),
    SPEC('smithwa', spec_dir),
    SPEC('swim', spec_dir)
]


def build_and_measure(benchmark, config, results_file, concurrent_id, run_id):
    os.environ['COMPILE_FLAGS'] = config

    build_result = subprocess.call(benchmark.build_command())
    if build_result != 0:
        return -1

    output_file = f"energy-monitor.{concurrent_id}.out"
    energy_monitor_command = [energy_monitor, "--output", output_file, "--command", f"\"{benchmark.run_command()}\""]

    total_energy = 0
    total_time = 0
    num_successes = 0

    for i in range(num_samples):
        p = subprocess.Popen(energy_monitor_command, stdout=subprocess.PIPE)
        result = p.stdout.read().decode("utf-8")
        energy = int(result.split(",")[0])
        time = float(result.split(",")[1])

        success = benchmark.run_successful(output_file)

        if success:
            total_energy += energy
            total_time += time
            num_successes += 1

        output = benchmark.display_name() + ","
        output += config + ","
        output += str(energy) + ","
        output += str(time) + ","
        output += str(success) + ","
        output += str(run_id) + "\n"
        if debug:
            print(output)
        else:
            results_file.write(output)


def do_ric(configs, benchmarks, concurrent_id):
    with open(configs, mode='r') as configs_file:
        with open(results_filename, mode='a', buffering=1) as results_file:
            results_file.write("Benchmark,Flags,Energy,Time,Success,RunId\n")

            for benchmark in benchmarks:
                # Run at -O3 to get a point of comparison
                build_and_measure(benchmark, '-O3', results_file, concurrent_id, -1)

                run_id = 0

                for config in configs_file:
                    build_and_measure(benchmark, config, results_file, concurrent_id, run_id)
                    run_id += 1
    return True


def main():
    parser = argparse.ArgumentParser(description='Run Random Iterative compilation.')
    parser.add_argument('--configs', type=str, required=True, help="The name of the file containing configs to use.")
    parser.add_argument('--benchmarks', type=str, required=True, help="Comma separated list of benchmarks to use or 'all'")
    parser.add_argument('--id', type=int, required=True, help="A value to identify this run from other concurrent runs.")
    args = parser.parse_args()

    benchmarks = available_benchmarks

    if args.benchmarks != 'all':
        enabled_benchmarks = args.benchmarks.lower().split(',')

        print(enabled_benchmarks)
        benchmarks = [b for b in available_benchmarks if b.name.lower() in enabled_benchmarks]

    print("Starting Combined Elimination for " + str(len(benchmarks)) + " benchmarks\n",flush=True)
    result = do_ric(args.configs, benchmarks, args.id)

    if result:
        return 0

    return 1


if __name__ == '__main__':
    main()

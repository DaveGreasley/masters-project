#!/usr/bin/env python

import sys
import time
import os
import argparse

from subprocess import call

from common.basedirectory import *
from common.benchmarkutils import get_available_benchmarks
from common.energyutils import measure

debug = False

energy_monitor = energy_monitor_dir + "/energy-monitor"
results_filename = base_dir + "/results/THREADS." + time.strftime("%Y%m%d-%H%M%S") + ".csv"

# This is the number of times the benchmark programs will be run
num_samples = 5
available_benchmarks = get_available_benchmarks()

def run_test(benchmark, num_threads, results_file, concurrent_id, run_id):
    os.environ['OMP_NUM_THREADS'] = str(num_threads)


    output_file = f"energy-monitor.{concurrent_id}.out"
    energy_monitor_command = [energy_monitor, "--output", output_file, "--command", benchmark.run_command()]

    total_energy = 0
    total_time = 0
    num_successes = 0

    for i in range(num_samples):
        energy, time = measure(energy_monitor_command)

        success = benchmark.run_successful(output_file)
        if success:
            total_energy += energy
            total_time += time
            num_successes += 1

        output = benchmark.display_name() + ","
        output += str(num_threads) + ","
        output += str(energy) + ","
        output += str(time) + ","
        output += str(success) + ","
        output += str(run_id) + "\n"
        if debug:
            print(output)
        else:
            results_file.write(output)


def test_threads(max_threads, benchmarks, concurrent_id):
    with open(results_filename, mode='a', buffering=1) as results_file:
        results_file.write("Benchmark,NumThreads,Energy,Time,Success,RunId\n")

        os.environ['COMPILE_FLAGS'] = '-O3' # Hardcode O3 for this test

        for benchmark in benchmarks:

            # First clean the benchmark build
            clean_result = call(benchmark.clean_command())
            if clean_result != 0:
                return False

            # Now build the benchmark
            build_result = call(benchmark.build_command())
            if build_result != 0:
                return False
            
            run_id = 0
            for thread_count in range(1, max_threads + 1):
                run_test(benchmark, thread_count, results_file, concurrent_id, run_id)
                run_id += 1
    return True


def main():
    parser = argparse.ArgumentParser(description='Test benchmarks on different thread counts.')
    parser.add_argument('--maxthreads', type=int, required=True, help="The maximum number of threads.")
    parser.add_argument('--benchmarks', type=str, required=True, help="Comma separated list of benchmarks to use or 'all'")
    parser.add_argument('--id', type=int, required=True, help="A value to identify this run from other concurrent runs.")
    args = parser.parse_args()

    benchmarks = available_benchmarks

    if args.benchmarks != 'all':
        enabled_benchmarks = args.benchmarks.lower().split(',')

        print(enabled_benchmarks)
        benchmarks = [b for b in available_benchmarks if b.name.lower() in enabled_benchmarks]

    print("Starting Thread tests for " + str(len(benchmarks)) + " benchmarks\n",flush=True)
    result = test_threads(args.maxthreads, benchmarks, args.id)

    if result:
        return 0

    return 1


if __name__ == '__main__':
    main()

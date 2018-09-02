#!/usr/bin/env python

import io

from subprocess import call

from common.basedirectory import *
import common.datautils as datautils
import common.energyutils as energyutils
import common.benchmarkutils as benchmarkutils

energy_monitor = energy_monitor_dir + "/energy-monitor"

# This is the number of times the benchmark programs will be run
num_samples = 5
best_configs = datautils.load_best_configurations()
benchmarks_to_test = best_configs.keys()


def build_and_measure(benchmark, reference_benchmark, config, results_file):
    os.environ['COMPILE_FLAGS'] = config

    # First clean the benchmark build
    clean_result = call(benchmark.clean_command())
    if clean_result != 0:
        return -1

    # Now build the benchmark
    build_result = call(benchmark.build_command())
    if build_result != 0:
        return -1

    output_file = f"energy-monitor.out"
    energy_monitor_command = [energy_monitor, "--output", output_file, "--command", f"\"{benchmark.run_command()}\""]

    total_energy = 0
    total_time = 0
    num_successes = 0

    for i in range(num_samples):
        energy, time = energyutils.measure(energy_monitor_command)

        success = benchmark.run_successful(output_file)
        if success:
            total_energy += energy
            total_time += time
            num_successes += 1

        output = reference_benchmark + ","
        output += benchmark.display_name() + ","
        output += str(energy) + ","
        output += str(time) + ","
        output += str(success) + ",\n"
        results_file.write(output)


with io.open(results_dir + '/cross_apply.results.csv', mode='w', buffering=1) as results_file:
    results_file.write('ReferenceBenchmark,ApplyToBenchmark,Energy,Time,Success\n')

    for reference_benchmark in benchmarks_to_test:
        reference_config = best_configs[reference_benchmark]

        for apply_to_benchmark in benchmarks_to_test:
            build_and_measure(benchmarkutils.get_benchmark(apply_to_benchmark), reference_benchmark, reference_config, results_file)

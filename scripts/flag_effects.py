#!/usr/bin/env python

import io
import time
from subprocess import call

from common.basedirectory import *
from common.energyutils import measure
from common.flagutils import load_o3_flags
from common.benchmarkutils import get_benchmark
from common.datautils import load_best_configurations

energy_monitor = energy_monitor_dir + "/energy-monitor"

# This is the number of times the benchmark programs will be run
num_samples = 5


def remove_o3_flags(long_config):
    o3_flags = load_o3_flags()

    long_flags = long_config.split(' ')
    return [f for f in long_flags if not f in o3_flags]


def build_and_measure(benchmark, config, disabled_flag, results_file):
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
        energy, time = measure(energy_monitor_command)

        success = benchmark.run_successful(output_file)
        if success:
            total_energy += energy
            total_time += time
            num_successes += 1

        output = benchmark.display_name() + ","
        output += disabled_flag + ","
        output += config + ","
        output += str(time) + ","
        output += str(energy) + ","
        output += str(success) + "\n"
        results_file.write(output)

    if num_successes == 0:
        return -1


with io.open(results_dir + '/flag_effects.' + time.strftime("%Y%m%d-%H%M%S" + ".csv"), mode='a', buffering=1) as results_file:
    results_file.write('Benchmark,DisabledFlag,Flags,Time,Energy,Success\n')

    best_configs = load_best_configurations()

    for benchmark_name in best_configs:
        benchmark = get_benchmark(benchmark_name)

        config = best_configs[benchmark.name]
        if config != '-O3':
            config = remove_o3_flags(config)

            for flag in config:
                config_to_test = ' '.join(config)
                config_to_test = config_to_test.replace(flag, '')

                build_and_measure(benchmark, config_to_test, flag, results_file)



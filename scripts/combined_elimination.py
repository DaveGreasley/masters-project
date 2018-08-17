#!/usr/bin/env python

import time
import os
import argparse

from subprocess import call 

from common.basedirectory import *
from common.energyutils import measure
from common.benchmarkutils import get_available_benchmarks
from common.flagutils import load_flag_list
from common.flagutils import build_config
from common.flagutils import get_cmd_string_from_config

debug = False

energy_monitor = energy_monitor_dir + "/energy-monitor"
results_filename = base_dir + "/results/CE." + time.strftime("%Y%m%d-%H%M%S") + ".csv"

# This is the number of times the benchmark programs will be run
num_samples = 3

all_flags = load_flag_list()
available_benchmarks = get_available_benchmarks()

def build_and_measure(benchmark, config, target_var, results_file, type, concurrent_id, run_id):
    config_str = get_cmd_string_from_config(config)

    os.environ['COMPILE_FLAGS'] = config_str

    # First clean the benchmark build
    clean_result = call(benchmark.clean_command())
    if clean_result != 0:
        return -1

    # Now build the benchmark
    build_result = call(benchmark.build_command())
    if build_result != 0:
        return -1

    output_file = f"energy-monitor.{concurrent_id}.out"
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
        output += config_str + ","
        output += str(energy) + ","
        output += str(time) + ","
        output += str(success) + ","
        output += type + ","
        output += str(run_id) + "\n"
        if debug:
            print(output)
        else:
            results_file.write(output)

    if num_successes == 0:
        return -1

    if target_var == 'energy':
        return total_energy / num_successes
    else:
        return total_time / num_successes


def combined_elimination(target_var, benchmarks, concurrent_id, base_flag='-O3'):

    with open(results_filename, mode='a', buffering=1) as results_file:
        results_file.write("Benchmark,Flags,Energy,Time,Success,Type,RunId\n")

        for benchmark in benchmarks:
            # Run at -O3 to get a point of comparison
            o3_flags = ['-O3']

            o3_result = build_and_measure(benchmark, o3_flags, target_var, results_file, 'O3', concurrent_id, -1)

            if o3_result <= 0:
                print('-- O3 build failed. Exiting')
                return False

            run_id = 0
            base_flags = all_flags.copy()

            # Start with all flags enabled for the base line
            base_config = build_config(all_flags, base_flags, base_flag)
            base_result = build_and_measure(benchmark, base_config, target_var, results_file, 'initial', concurrent_id, run_id)

            if base_result <= 0:
                print('-- Base build failed. Exiting')
                return False

            run_id += 1

            improvement = True
            flags_to_consider = base_flags.copy()
            while improvement:
                improvement = False
                flags_with_improvement = []

                for flag in flags_to_consider:
                    # do a run with each flag disabled in turn
                    tmp_flags = list(base_flags)
                    tmp_flags.remove(flag)

                    tmp_config = build_config(all_flags, tmp_flags, base_flag)

                    result = build_and_measure(benchmark, tmp_config, target_var, results_file, 'test', concurrent_id, run_id)

                    if 0 <= result < base_result:
                        flags_with_improvement += ([(flag, result)])

                    run_id += 1

                # Starting from the biggest improvement, check if disabling the
                # flag still brings improvement. If it does, then permanently
                # disable the flag, update the base flag configuration and remeasure
                flags_with_improvement = sorted(flags_with_improvement, key=lambda x: x[1])
                for flag, result in flags_with_improvement:
                    # do a run with each flag disabled in turn
                    tmp_flags = base_flags.copy()
                    tmp_flags.remove(flag)
                    tmp_config = build_config(all_flags, tmp_flags, base_flag)

                    test_result = build_and_measure(benchmark, tmp_config, target_var, results_file, 'test', concurrent_id, run_id)

                    if test_result <= 0:
                        print('-- Test run ' + str(run_id) + ' failed. Exiting')
                        return False

                    run_id += 1

                    if test_result < base_result:
                        # remove the flag permanently from the baseline build, and
                        # remove it from further consideration
                        base_flags.remove(flag)
                        flags_to_consider.remove(flag)

                        # build and measure the new baseline
                        tmp_flags = build_config(all_flags, base_flags, base_flag)

                        base_result = build_and_measure(benchmark, tmp_flags, target_var, results_file, 'baseline', concurrent_id, run_id)
                        if base_result <= 0:
                            print('-- Base run ' + str(run_id) + ' failed. Exiting')
                            return False

                        run_id += 1
                        improvement = True


def main():
    parser = argparse.ArgumentParser(description='Run Combined Elimination..')
    parser.add_argument('--variable', type=str, required=True, help="The variable to optimise for: energy or  time")
    parser.add_argument('--benchmarks', type=str, required=True, help="Comma separated list of benchmarks to use or 'all'")
    parser.add_argument('--id', type=int, required=True, help="A value to identify this run from other concurrent runs.")
    args = parser.parse_args()

    benchmarks = available_benchmarks

    if args.benchmarks != 'all':
        enabled_benchmarks = args.benchmarks.lower().split(',')

        print(enabled_benchmarks)
        benchmarks = [b for b in available_benchmarks if b.name.lower() in enabled_benchmarks]

    print("Starting Combined Elimination for " + str(len(benchmarks)) + " benchmarks\n",flush=True)
    result = combined_elimination(args.variable, benchmarks, args.id)

    if result:
        return 0

    return 1


if __name__ == '__main__':
    main()

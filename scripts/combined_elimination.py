#!/usr/bin/env python3

import argparse
import time
import os
import subprocess
import sys

from model import NPB

debug = False

#base_dir = "/home/dave/Documents/project"
#base_dir = "/mnt/storage/home/dg17763/masters-project"
base_dir = "/home/dave/masters-project/"
results_dir = base_dir + "/results"
npb_dir = base_dir + "/benchmarks/NPB3.3-OMP"
energy_monitor_dir = base_dir + "/energy-monitor"

build_dirs = {"npb": npb_dir}
bin_dirs = {"npb": npb_dir + "/bin"}

energy_monitor = energy_monitor_dir + "/energy-monitor"
results_filename = base_dir + "/results/CE." + time.strftime("%Y%m%d-%H%M%S") + ".csv"

# This is the number of times the benchmark programs will be run
num_samples = 3

benchmarks = [
    NPB('BT', 'C'),
    # NPB('BT', 'C', version='VEC'),
    NPB('CG', 'C'),
    NPB('EP', 'D'),
    NPB('FT', 'C'),
    NPB('IS', 'D'),
    NPB('LU', 'C'),
    #NPB('LU', 'C', version='VEC'),
    NPB('MG', 'C'),
    NPB('SP', 'C'),
    NPB('UA', 'C')
]

### Above O3 Flags
all_flags = [
'-fbranch-target-load-optimize',
'-fbranch-target-load-optimize2',
'-fbtr-bb-exclusive',
'-fconserve-stack',
'-fdelayed-branch',
'-fdelete-dead-exceptions',
'-fexceptions',
'-fgcse-las',
'-fgcse-sm',
'-fgraphite',
'-fgraphite-identity',
'-fipa-pta',
'-fira-loop-pressure',
'-fisolate-erroneous-paths-attribute',
'-fkeep-gc-roots-live',
'-flimit-function-alignment',
'-flive-range-shrinkage',
'-floop-nest-optimize',
'-floop-parallelize-all',
'-fmodulo-sched',
'-fmodulo-sched-allow-regmoves',
'-fnon-call-exceptions',
'-fnothrow-opt',
'-fomit-frame-pointer',
'-fopt-info',
'-fpack-struct',
'-freg-struct-return',
'-freschedule-modulo-scheduled-loops',
'-fsched-pressure',
'-fsched-spec-load',
'-fsched-spec-load-dangerous',
'-fsched-stalled-insns',
'-fsched2-use-superblocks',
'-fschedule-insns',
'-fsel-sched-pipelining',
'-fsel-sched-pipelining-outer-loops',
'-fsel-sched-reschedule-pipelined',
'-fselective-scheduling',
'-fselective-scheduling2',
'-fshort-wchar',
'-fstack-protector',
'-fstack-protector-all',
'-fstack-protector-explicit',
'-fstack-protector-strong',
'-fstrict-enums',
'-ftracer',
'-ftrapv',
'-ftree-loop-distribution',
'-ftree-lrs',
'-ftree-vectorize',
'-funconstrained-commons',
'-funroll-all-loops',
'-funroll-loops',
'-funwind-tables',
'-fvar-tracking-assignments-toggle',
'-fvar-tracking-uninit',
'-fvariable-expansion-in-unroller',
'-fwrapv'
]

### O1 - O3 Flags
#all_flags = [
#        '-falign-functions',
#        '-falign-jumps',
#        '-falign-labels',
#        '-falign-loops',
#        '-fbranch-count-reg',
#        '-fcaller-saves',
#        '-fcode-hoisting',
#        '-fcombine-stack-adjustments',
#        '-fcompare-elim',
#        '-fcprop-registers',
#        '-fcrossjumping',
#        '-fcse-follow-jumps',
#        '-fdefer-pop',
#        '-fdevirtualize',
#        '-fdevirtualize-speculatively',
#        '-fexpensive-optimizations',
#        '-fforward-propagate',
#        '-fgcse',
#        '-fgcse-after-reload',
#        '-fguess-branch-probability',
#        '-fhoist-adjacent-loads',
#        '-fif-conversion',
#        '-fif-conversion2',
#        '-findirect-inlining',
#        '-finline-functions',
#        '-finline-functions-called-once',
#        '-finline-small-functions',
#        '-fipa-bit-cp',
#        '-fipa-cp',
#        '-fipa-cp-clone',
#        '-fipa-icf',
#        '-fipa-icf-functions',
#        '-fipa-icf-variables',
#        '-fipa-profile',
#        '-fipa-pure-const',
#        '-fipa-ra',
#        '-fipa-reference',
#        '-fipa-sra',
#        '-fipa-vrp',
#        '-fisolate-erroneous-paths-dereference',
#        '-flra-remat',
#        '-fmove-loop-invariants',
#        '-foptimize-sibling-calls',
#        '-foptimize-strlen',
#        '-fpartial-inlining',
#        '-fpeel-loops',
#        '-fpeephole2',
#        '-fpredictive-commoning',
#        '-freorder-blocks',
#        '-freorder-blocks-and-partition',
#'-freorder-functions',
#'-frerun-cse-after-loop',
#'-fschedule-insns2',
#'-fshrink-wrap',
#'-fsplit-loops',
#'-fsplit-paths',
#'-fsplit-wide-types',
#'-fssa-phiopt',
#'-fstore-merging',
#'-fstrict-overflow',
#'-fthread-jumps',
#'-ftree-bit-ccp',
#'-ftree-builtin-call-dce',
#'-ftree-ccp',
#'-ftree-ch',
#'-ftree-coalesce-vars',
#'-ftree-copy-prop',
#'-ftree-dce',
#'-ftree-dominator-opts',
#'-ftree-dse',
#'-ftree-fre',
#'-ftree-loop-distribute-patterns',
#'-ftree-loop-vectorize',
#'-ftree-partial-pre',
#'-ftree-pre',
#'-ftree-pta',
#'-ftree-sink',
#'-ftree-slp-vectorize',
#'-ftree-slsr',
#'-ftree-sra',
#'-ftree-switch-conversion',
#'-ftree-tail-merge',
#'-ftree-ter',
#'-ftree-vrp',
#'-funswitch-loops',
#
#]

def build_config(all_flags, enabled_flags, base_flag=''):
    config = []
    if base_flag != '':
        config.append(base_flag)

    for f in enabled_flags:
        assert f in all_flags

    for f in all_flags:
        if f in enabled_flags:
            config.append(f)
        else:
            config.append('-fno-' + f[2:])
    return config


def get_cmd_string_from_config(config):
    return ' '.join(config)

#
# energy_temp = 1000
# time_temp = 1000


def build_and_measure(benchmark, config, target_var, results_file):
    # global energy_temp
    # global time_temp

    config_str = get_cmd_string_from_config(config)

    os.environ['COMPILE_FLAGS'] = config_str

    build_dir = build_dirs[benchmark.suite]
    bin_dir = bin_dirs[benchmark.suite]

    build_result = subprocess.call(benchmark.build_command(build_dir))
    if build_result != 0:
        return -1

    energy_monitor_command = [energy_monitor, bin_dir + "/" + benchmark.binary_name()]

    total_energy = 0
    total_time = 0
    num_successes = 0

    for i in range(num_samples):
        p = subprocess.Popen(energy_monitor_command, stdout=subprocess.PIPE)
        result = p.stdout.read().decode("utf-8")
        energy = int(result.split(",")[0])
        time = float(result.split(",")[1])

        # energy_temp -= 1
        # energy = energy_temp
        #
        # time_temp -= 1
        # time = time_temp

        success = benchmark.run_successful()

        if success:
            total_energy += energy
            total_time += time
            num_successes += 1

        output = benchmark.binary_name() + ","
        output += config_str + ","
        output += str(energy) + ","
        output += str(time) + ","
        output += str(success) + "\n"
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


def combined_elimination(target_var, base_flag='-O3'):

    with open(results_filename, mode='a', buffering=1) as results_file:
        results_file.write("Benchmark,Flags,Energy,Time,Success\n")

        for benchmark in benchmarks:
            # Run at -O3 to get a point of comparison
            o3_flags = ['-O3']

            o3_result = build_and_measure(benchmark, o3_flags, target_var, results_file)

            if o3_result <= 0:
                print('-- O3 build failed. Exiting')
                return False

            run_id = 0
            base_flags = all_flags.copy()

            # Start with all flags enabled for the base line
            base_config = build_config(all_flags, base_flags, base_flag)
            base_result = build_and_measure(benchmark, base_config, target_var, results_file)
            initial_base_result = base_result

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

                    result = build_and_measure(benchmark, tmp_config, target_var, results_file)

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

                    test_result = build_and_measure(benchmark, tmp_config, target_var, results_file)

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

                        base_result = build_and_measure(benchmark, tmp_flags, target_var, results_file)
                        if base_result <= 0:
                            print('-- Base run ' + str(run_id) + ' failed. Exiting')
                            return False

                        run_id += 1
                        improvement = True


def main():
    result = combined_elimination('energy')

    if result:
        return 0

    return 1


if __name__ == '__main__':
    main()

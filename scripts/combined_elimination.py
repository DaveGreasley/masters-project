#!/usr/bin/env python

import time
import os
import argparse

from subprocess import call 

from model import NPB
from model import SPEC

from energyutils import measure

debug = False

#base_dir = "/home/dave/Documents/project"
base_dir = "/mnt/storage/home/dg17763/masters-project"
#base_dir = "/home/dave/masters-project/"
results_dir = base_dir + "/results"
npb_dir = base_dir + "/benchmarks/NPB3.3-OMP"
spec_dir = base_dir + "/benchmarks/spec_omp2012"
energy_monitor_dir = base_dir + "/energy-monitor"


energy_monitor = energy_monitor_dir + "/energy-monitor"
results_filename = base_dir + "/results/CE." + time.strftime("%Y%m%d-%H%M%S") + ".csv"

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
    SPEC('imagick', spec_dir),
    SPEC('smithwa', spec_dir),
    SPEC('swim', spec_dir)
]

all_flags = [
    '-faggressive-loop-optimizations',
    '-falign-functions',
    '-falign-jumps',
    '-falign-labels',
    '-falign-loops',
    '-fasynchronous-unwind-tables',
    '-fauto-inc-dec',
    '-fbranch-count-reg',
    '-fbranch-target-load-optimize',
    '-fbranch-target-load-optimize2',
    '-fbtr-bb-exclusive',
    '-fcaller-saves',
    '-fcode-hoisting',
    '-fcombine-stack-adjustments',
    '-fcompare-elim',
    '-fconserve-stack',
    '-fcprop-registers',
    '-fcrossjumping',
    '-fcse-follow-jumps',
    '-fdce',
    '-fdefer-pop',
    '-fdelayed-branch',
    '-fdelete-dead-exceptions',
    '-fdelete-null-pointer-checks',
    '-fdevirtualize',
    '-fdevirtualize-speculatively',
    '-fdse',
    '-fearly-inlining',
    '-fexceptions',
    '-fexpensive-optimizations',
    '-fforward-propagate',
    '-ffunction-cse',
    '-fgcse',
    '-fgcse-after-reload',
    '-fgcse-las',
    '-fgcse-lm',
    '-fgcse-sm',
    '-fgraphite',
    '-fgraphite-identity',
    '-fguess-branch-probability',
    '-fhoist-adjacent-loads',
    '-fif-conversion',
    '-fif-conversion2',
    '-findirect-inlining',
    '-finline',
    '-finline-atomics',
    '-finline-functions',
    '-finline-functions-called-once',
    '-finline-small-functions',
    '-fipa-bit-cp',
    '-fipa-cp',
    '-fipa-cp-clone',
    '-fipa-icf',
    '-fipa-icf-functions',
    '-fipa-icf-variables',
    '-fipa-profile',
    '-fipa-pta',
    '-fipa-pure-const',
    '-fipa-ra',
    '-fipa-reference',
    '-fipa-sra',
    '-fipa-vrp',
    '-fira-hoist-pressure',
    '-fira-loop-pressure',
    '-fira-share-save-slots',
    '-fira-share-spill-slots',
    '-fisolate-erroneous-paths-attribute',
    '-fisolate-erroneous-paths-dereference',
    '-fivopts',
    '-fjump-tables',
    '-fkeep-gc-roots-live',
    '-flimit-function-alignment',
    '-flive-range-shrinkage',
    '-floop-nest-optimize',
    '-floop-parallelize-all',
    '-flra-remat',
    '-fmodulo-sched',
    '-fmodulo-sched-allow-regmoves',
    '-fmove-loop-invariants',
    '-fnon-call-exceptions',
    '-fnothrow-opt',
    '-fomit-frame-pointer',
    '-fopt-info',
    '-foptimize-sibling-calls',
    '-foptimize-strlen',
    '-fpack-struct',
    '-fpartial-inlining',
    '-fpeel-loops',
    '-fpeephole',
    '-fpeephole2',
    '-fplt',
    '-fpredictive-commoning',
    '-fprefetch-loop-arrays',
    '-fprintf-return-value',
    '-freg-struct-return',
    '-frename-registers',
    '-freorder-blocks',
    '-freorder-blocks-and-partition',
    '-freorder-functions',
    '-frerun-cse-after-loop',
    '-freschedule-modulo-scheduled-loops',
    '-frtti',
    '-fsched-critical-path-heuristic',
    '-fsched-dep-count-heuristic',
    '-fsched-group-heuristic',
    '-fsched-interblock',
    '-fsched-last-insn-heuristic',
    '-fsched-pressure',
    '-fsched-rank-heuristic',
    '-fsched-spec',
    '-fsched-spec-insn-heuristic',
    '-fsched-spec-load',
    '-fsched-spec-load-dangerous',
    '-fsched-stalled-insns',
    '-fsched-stalled-insns-dep',
    '-fsched2-use-superblocks',
    '-fschedule-fusion',
    '-fschedule-insns',
    '-fschedule-insns2',
    '-fsel-sched-pipelining',
    '-fsel-sched-pipelining-outer-loops',
    '-fsel-sched-reschedule-pipelined',
    '-fselective-scheduling',
    '-fselective-scheduling2',
    '-fshort-enums',
    '-fshort-wchar',
    '-fshrink-wrap',
    '-fshrink-wrap-separate',
    '-fsplit-ivs-in-unroller',
    '-fsplit-loops',
    '-fsplit-paths',
    '-fsplit-wide-types',
    '-fssa-backprop',
    '-fssa-phiopt',
    '-fstack-protector',
    '-fstack-protector-all',
    '-fstack-protector-explicit',
    '-fstack-protector-strong',
    '-fstdarg-opt',
    '-fstore-merging',
    '-fstrict-enums',
    '-fstrict-overflow',
    '-fstrict-volatile-bitfields',
    '-fthread-jumps',
    '-fno-threadsafe-statics',
    '-ftracer',
    '-ftrapv',
    '-ftree-bit-ccp',
    '-ftree-builtin-call-dce',
    '-ftree-ccp',
    '-ftree-ch',
    '-ftree-coalesce-vars',
    '-ftree-copy-prop',
    '-ftree-cselim',
    '-ftree-dce',
    '-ftree-dominator-opts',
    '-ftree-dse',
    '-ftree-forwprop',
    '-ftree-fre',
    '-ftree-loop-distribute-patterns',
    '-ftree-loop-distribution',
    '-ftree-loop-if-convert',
    '-ftree-loop-im',
    '-ftree-loop-ivcanon',
    '-ftree-loop-optimize',
    '-ftree-loop-vectorize',
    '-ftree-lrs',
    '-ftree-partial-pre',
    '-ftree-phiprop',
    '-ftree-pre',
    '-ftree-pta',
    '-ftree-reassoc',
    '-ftree-scev-cprop',
    '-ftree-sink',
    '-ftree-slp-vectorize',
    '-ftree-slsr',
    '-ftree-sra',
    '-ftree-switch-conversion',
    '-ftree-tail-merge',
    '-ftree-ter',
    '-ftree-vectorize',
    '-ftree-vrp',
    '-funconstrained-commons',
    '-funroll-all-loops',
    '-funroll-loops',
    '-funswitch-loops',
    '-funwind-tables',
    '-fvar-tracking',
    '-fvar-tracking-assignments',
    '-fvar-tracking-assignments-toggle',
    '-fvar-tracking-uninit',
    '-fvariable-expansion-in-unroller',
    '-fweb',
    '-fwrapv'
]


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

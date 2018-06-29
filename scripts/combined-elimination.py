#!/usr/bin/env python3

import argparse
import os
import subprocess
import sys

from model import NPB

base_dir = "/home/dave/Documents/project"
results_dir = base_dir + "/results"
npb_dir = base_dir + "/benchmarks/NPB3.3-OMP"
energy_monitor_dir = base_dir + "/energy-monitor"
bin_dirs = {"npb": npb_dir + "/bin"}

# This is the number of times the benchmark programs will be run
num_samples = 3

benchmarks = [
    NPB('BT', 'C'),
    NPB('BT', 'C', version='VEC'),
    NPB('CG', 'C'),
    NPB('EP', 'D'),
    NPB('FT', 'C'),
    NPB('IS', 'C'),
    NPB('LU', 'C'),
    NPB('LU', 'C', version='VEC'),
    NPB('MG', 'D'),
    NPB('SP', 'C')
]

all_flags = [
    # '-faggressive-loop-optimizations', # Not supported in 4.5
    '-falign-functions',
    '-falign-jumps',
    '-falign-labels',
    '-falign-loops',
    '-fbranch-count-reg',
    '-fbranch-target-load-optimize',
    '-fbranch-target-load-optimize2',
    '-fbtr-bb-exclusive',
    '-fcaller-saves',
    # '-fcombine-stack-adjustments',     # Not supported in 4.5
    # '-fcommon',                        # affects semantics, unlikely to affect performance
    # '-fcompare-elim',                  # Not supported in 4.5
    '-fconserve-stack',
    '-fcprop-registers',
    '-fcrossjumping',
    '-fcse-follow-jumps',
    # '-fdata-sections',                 # affects semantics unlikely to affect performance
    '-fdce',
    '-fdefer-pop',
    '-fdelete-null-pointer-checks',
    # '-fdevirtualize',                  # Not supported in 4.5
    '-fdse',
    '-fearly-inlining',
    '-fexpensive-optimizations',
    '-fforward-propagate',
    '-fgcse',
    '-fgcse-after-reload',
    '-fgcse-las',
    '-fgcse-lm',
    '-fgcse-sm',
    '-fguess-branch-probability',
    # '-fhoist-adjacent-loads',          # Not supported in 4.5
    '-fif-conversion',
    '-fif-conversion2',
    '-finline',
    # '-finline-atomics',                # Not supported in 4.5
    '-finline-functions',
    '-finline-functions-called-once',
    '-finline-small-functions',
    '-fipa-cp',
    '-fipa-cp-clone',
    # '-fipa-profile',                   # Not supported in 4.5
    '-fipa-pta',
    '-fipa-pure-const',
    '-fipa-reference',
    '-fipa-sra',
    # '-fira-hoist-pressure',            # Not supported in 4.5
    '-fivopts',
    '-fmerge-constants',
    '-fmodulo-sched',
    '-fmove-loop-invariants',
    '-fomit-frame-pointer',
    '-foptimize-sibling-calls',
    # '-foptimize-strlen',               # Not supported in 4.5
    '-fpeephole',
    '-fpeephole2',
    '-fpredictive-commoning',
    '-fprefetch-loop-arrays',
    '-fregmove',
    '-frename-registers',
    '-freorder-blocks',
    '-freorder-functions',
    '-frerun-cse-after-loop',
    '-freschedule-modulo-scheduled-loops',
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
    '-fsched-stalled-insns',
    '-fsched-stalled-insns-dep',
    '-fschedule-insns',
    '-fschedule-insns2',
    # '-fsection-anchors',               # may conflict with other flags
    '-fsel-sched-pipelining',
    '-fsel-sched-pipelining-outer-loops',
    '-fsel-sched-reschedule-pipelined',
    '-fselective-scheduling',
    '-fselective-scheduling2',
    # '-fshrink-wrap',                   # Not supported in 4.5
    '-fsplit-ivs-in-unroller',
    '-fsplit-wide-types',
    # '-fstrict-aliasing',               # affects semantics
    '-fthread-jumps',
    '-ftoplevel-reorder',
    # '-ftree-bit-ccp',                  # Not supported in 4.5
    '-ftree-builtin-call-dce',
    '-ftree-ccp',
    '-ftree-ch',
    # '-ftree-coalesce-inlined-vars',    # No equivalent -fno for this flag
    # '-ftree-coalesce-vars',            # Not supported in 4.5
    '-ftree-copy-prop',
    '-ftree-copyrename',
    '-ftree-cselim',
    '-ftree-dce',
    '-ftree-dominator-opts',
    '-ftree-dse',
    '-ftree-forwprop',
    '-ftree-fre',
    # '-ftree-loop-distribute-patterns', # Not supported in 4.5
    '-ftree-loop-distribution',
    # '-ftree-loop-if-convert',          # Not supported in 4.5
    '-ftree-loop-im',
    '-ftree-loop-ivcanon',
    '-ftree-loop-optimize',
    # '-ftree-partial-pre',              # Not supported in 4.5
    '-ftree-phiprop',
    '-ftree-pre',
    '-ftree-pta',
    '-ftree-reassoc',
    '-ftree-scev-cprop',
    '-ftree-sink',
    '-ftree-slp-vectorize',
    # '-ftree-slsr',                     # Not supported in 4.5
    '-ftree-sra',
    '-ftree-switch-conversion',
    # '-ftree-tail-merge',               # Not supported in 4.5
    '-ftree-ter',
    '-ftree-vect-loop-version',
    '-ftree-vectorize',
    '-ftree-vrp',
    '-funroll-all-loops',
    '-funroll-loops',
    '-funswitch-loops',
    '-fvariable-expansion-in-unroller',
    '-fvect-cost-model',
    '-fweb'
]


def build_and_measure(benchmark, flags, build_id, target_var, results_file):
    os.environ['COMPILE_FLAGS'] = flags

    subprocess.call(benchmark.build_command())

    bin_dir = bin_dirs[benchmark.suite]
    energy_monitor_command = [energy_monitor_dir + "/energy-monitor", bin_dir + "/" + benchmark.binary_name()]

    average_energy = 0
    average_time = 0

    for i in range(0, num_samples):
        p = subprocess.Popen(energy_monitor_command, stdout=subprocess.PIPE)
        result = p.stdout.read().decode("utf-8")
        energy = int(result.split(",")[0])
        time = float(result.split(",")[1])

        average_energy += energy
        average_time += time

        success = benchmark.run_successful()

        output = build_id + ","
        output += benchmark.display_name() + ","
        output += str(energy) + ","
        output += str(time) + ","
        output += str(success) + "\n"
        results_file.write(output)

    average_energy = average_energy / num_samples
    average_time = average_time / num_samples

    if target_var == 'energy':
        return average_energy
    else:
        return average_time

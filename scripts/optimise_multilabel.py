#!/usr/bin/env python

import io
import time
import os
from subprocess import call

from sklearn.model_selection import KFold
from sklearn.svm import SVC

from skmultilearn.problem_transform import ClassifierChain

import common.basedirectory as basedirectory
import common.datautils as datautils
import common.benchmarkutils as benchmarkutils
import common.energyutils as energyutils
import common.flagutils as flagutils

# Ensure script runs on isolated copy of benchmarks
import common.isolateutils as isolateutils

energy_monitor = basedirectory.energy_monitor_dir + "/energy-monitor"
results_filename = basedirectory.results_dir + '/ML.' + time.strftime("%Y%m%d-%H%M%S" + ".csv")

# This is the number of times the benchmark programs will be run
num_samples = 5

best_configs = datautils.load_best_configurations()
benchmarks_to_test = best_configs.keys()


def build_and_measure(benchmark, config, results_file):
    os.environ['COMPILE_FLAGS'] = config

    # First clean the benchmark build
    clean_result = call(benchmark.clean_command())
    if clean_result != 0:
        print("Failed to clean " + benchmark.display_name())
        exit()

    # Now build the benchmark
    build_result = call(benchmark.build_command())
    if build_result != 0:
        print("Failed to build" + benchmark.display_name())
        exit()

    output_file = f"energy-monitor.out"
    energy_monitor_command = [energy_monitor, "--output", output_file, "--command", benchmark.run_command()]

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

        output = benchmark.display_name() + ","
        output += config + ","
        output += str(energy) + ","
        output += str(time) + ","
        output += str(success) + "\n"
        results_file.write(output)


print("Running in isolation at: " + isolateutils._temp_dir)


with io.open(results_filename, mode='a', buffering=1) as results_file:
    results_file.write('Benchmark,Flags,Energy,Time,Success\n')

    average_data = datautils.load_ce_results(basedirectory.results_dir + '/CE.results.zip')
    benchmarks = average_data["Benchmark"].unique()

    X, y = datautils.format_data_for_multilabel(average_data, False, benchmarks)
    y, remaining_labels = flagutils.remove_static_labels(y, with_labels=True)

    kf = KFold(n_splits=len(y))
    for train_index, test_index in kf.split(X):
        X_train, X_test = X[train_index], X[test_index]
        y_train, y_test = y[train_index], y[test_index]

        clf = ClassifierChain(SVC(kernel='rbf', C=0.01, gamma=0.01))
        clf.fit(X_train, y_train)
        prediction = clf.predict(X_test).toarray()

        config = "-O3 "

        for index, flag_enabled in enumerate(prediction[0]):
            if flag_enabled:
                config += remaining_labels[0][index] + " "
            else:
                config += "-fno-" + remaining_labels[0][index][2:] + " "

        build_and_measure(benchmarkutils.get_benchmark(benchmarks[test_index][0]), config, results_file)

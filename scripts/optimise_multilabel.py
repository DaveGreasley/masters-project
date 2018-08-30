#!/usr/bin/env python

import io
import time
from subprocess import call

from sklearn.preprocessing import StandardScaler
from sklearn.model_selection import KFold
from sklearn.svm import SVC

from skmultilearn.problem_transform import ClassifierChain

from common.basedirectory import *
from common.datautils import load_ce_results
from common.datautils import load_best_configurations
from common.datautils import format_data_for_multilabel
from common.featuresutils import load_features
from common.benchmarkutils import get_benchmark
from common.energyutils import measure
from common.flagutils import remove_static_labels

energy_monitor = energy_monitor_dir + "/energy-monitor"

# This is the number of times the benchmark programs will be run
num_samples = 5

best_configs = load_best_configurations()
benchmarks_to_test = best_configs.keys()


def build_and_measure(benchmark, with_dwarf, config, results_file):
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
        energy, time = measure(energy_monitor_command)

        success = benchmark.run_successful(output_file)
        if success:
            total_energy += energy
            total_time += time
            num_successes += 1

        output = benchmark.display_name() + ","
        output += str(with_dwarf) + ","
        output += config + ","
        output += str(time) + ","
        output += str(energy) + ","
        output += str(success) + "\n"
        results_file.write(output)


dwarf_options = [True, False]

with io.open(results_dir + '/ML.' + time.strftime("%Y%m%d-%H%M%S" + ".csv"), mode='a', buffering=1) as results_file:
    results_file.write('Benchmark,WithDwarf,Flags,Time,Energy,Success\n')

    average_data = load_ce_results(results_dir + '/CE.results.zip')
    benchmarks = average_data["Benchmark"].unique()

    for with_dwarf in dwarf_options:

        X, y = format_data_for_multilabel(average_data, False, benchmarks)
        y, remaining_labels = remove_static_labels(y, with_labels=True)

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

            build_and_measure(get_benchmark(benchmarks[test_index][0]), with_dwarf, config, results_file)

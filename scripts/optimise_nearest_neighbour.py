#!/usr/bin/env python

import io
import time
from subprocess import call

from sklearn.preprocessing import StandardScaler
from sklearn.model_selection import KFold
from sklearn.neighbors import KNeighborsClassifier

from common.basedirectory import *
from common.datautils import load_best_configurations
from common.featuresutils import load_features
from common.benchmarkutils import get_benchmark
from common.energyutils import measure

energy_monitor = energy_monitor_dir + "/energy-monitor"

# This is the number of times the benchmark programs will be run
num_samples = 5

best_configs = load_best_configurations()
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
        energy, time = measure(energy_monitor_command)

        success = benchmark.run_successful(output_file)
        if success:
            total_energy += energy
            total_time += time
            num_successes += 1

        output = benchmark.display_name() + ","
        output += config + ","
        output += str(time) + ","
        output += str(energy) + ","
        output += str(success) + "\n"
        results_file.write(output)


X, y = load_features(benchmarks_to_test, with_dwarf=False, with_names=True)
X = StandardScaler().fit_transform(X)


with io.open(results_dir + '/NN.' + time.strftime("%Y%m%d-%H%M%S" + ".csv"), mode='a', buffering=1) as results_file:
    results_file.write('Benchmark,Flags,Time,Energy,Success\n')

    kf = KFold(n_splits=len(y))
    for train_index, test_index in kf.split(X):
        X_train, X_test = X[train_index], X[test_index]
        y_train, y_test = y[train_index], y[test_index]

        nn = KNeighborsClassifier(n_neighbors=1)
        nn.fit(X_train, y_train)
        prediction = nn.predict(X_test)

        for i in range(len(prediction)):
            predicted_config = best_configs[prediction[i]]
            test_benchmark = get_benchmark(y_test[i])

            build_and_measure(test_benchmark, predicted_config, results_file)

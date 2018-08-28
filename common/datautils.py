import zipfile as zip
import pandas as pd

from common.basedirectory import *


def load_ce_results(filename):
    with zip.ZipFile(filename) as results_zip:
        with results_zip.open(results_zip.namelist()[0]) as results_file:
            data = pd.read_csv(results_file)
            data.loc[:, 'Energy'] *= 1e-6 # Convert energy to Joules
            data.loc[:, 'Benchmark'] = data['Benchmark'].str.replace('.x', '')

            return data.groupby(['Benchmark','Flags', 'Type', 'RunId'], as_index=False).agg({'Energy':'mean', 'Time':'mean'})


def best_configuration(variable, benchmark, average_data):
    benchmark_data = average_data.loc[average_data["Benchmark"] == benchmark]
    min_index = benchmark_data[variable].idxmin()
    return benchmark_data.loc[min_index]["Flags"]


def load_best_configurations(average_data=None):
    if average_data is None:
        average_data = load_ce_results(results_dir + '/CE.results.zip')

    benchmarks = average_data["Benchmark"].unique()

    best_configs = {}
    for benchmark in benchmarks:
        best_configs[benchmark.split('.')[0]] = best_configuration('Energy', benchmark, average_data)

    return best_configs

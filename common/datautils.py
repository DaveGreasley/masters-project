import zipfile as zip
import pandas as pd
import numpy as np

from sklearn.preprocessing import StandardScaler

from common.basedirectory import *
from common.featuresutils import load_features
from common.flagutils import get_o3_config
from common.flagutils import load_flag_list


def load_ce_results(filename):
    with zip.ZipFile(filename) as results_zip:
        with results_zip.open(results_zip.namelist()[0]) as results_file:
            data = pd.read_csv(results_file)
            data.loc[:, 'Energy'] *= 1e-6 # Convert energy to Joules
            data.loc[:, 'Benchmark'] = data['Benchmark'].apply(lambda x: x.split('.')[0])

            return data.groupby(['Benchmark','Flags', 'Type', 'RunId', 'Success'], as_index=False).agg({'Energy':'mean', 'Time':'mean'})


def load_csv_results(filename, group_by_cols, successful_only=True):
    data = pd.read_csv(filename)
    data.loc[:, 'Energy'] *= 1e-6  # Convert energy to Joules
    data.loc[:, 'Benchmark'] = data['Benchmark'].apply(lambda x: x.split('.')[0])

    average_data = data.groupby(group_by_cols, as_index = False).agg({'Energy': 'mean', 'Time': 'mean'})

    if successful_only:
        average_data = average_data[average_data["Success"] == True]

    return average_data


def best_configuration(variable, benchmark, average_data):
    return best_configuration_data(variable, benchmark, average_data, ["Flags"])[0]


def best_configuration_data(variable, benchmark, average_data, fields):
    benchmark_data = average_data.loc[average_data["Benchmark"].str.lower() == benchmark.lower()]
    min_index = benchmark_data[variable].idxmin()
    return benchmark_data.loc[min_index][fields]


def load_best_configurations(average_data=None):
    if average_data is None:
        average_data = load_ce_results(results_dir + '/CE.results.zip')

    benchmarks = average_data["Benchmark"].unique()

    best_configs = {}
    for benchmark in benchmarks:
        best_configs[benchmark.split('.')[0]] = best_configuration('Energy', benchmark, average_data)

    return best_configs


def format_data_for_multilabel(data, with_dwarf, benchmarks):
    all_flags = load_flag_list()
    benchmarks_nosize = [b.split('.')[0] for b in benchmarks]

    X = StandardScaler().fit_transform(load_features(benchmarks_nosize, with_dwarf=with_dwarf))
    y = []

    for benchmark in benchmarks:
        config_str = best_configuration('Energy', benchmark, data)
        if config_str == '-O3':
            config_str = get_o3_config()

        labels = []

        config = config_str[4:].split(' ')
        for i, flag in enumerate(config):
            if flag == all_flags[i]:
                labels.append(1)  # Flag is turned on
            elif flag == '-fno-' + all_flags[i][2:]:
                labels.append(0)  # FLag is turned off -fno
            else:
                print("ERROR:" + flag)

        y.append(labels)

    return X, np.array(y)
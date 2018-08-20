import pandas as pd
import numpy as np

import sys
sys.path.insert(0,'../')

from sklearn.model_selection import cross_val_score
from sklearn.svm import SVC
from skmultilearn.problem_transform import BinaryRelevance

from common.featuresutils import load_features
from common.flagutils import load_flag_list
from common.flagutils import load_o3_flags
from common.flagutils import build_config
from common.flagutils import get_cmd_string_from_config


def best_configuration(variable, benchmark, average_data):
    benchmark_data = average_data.loc[average_data["Benchmark"] == benchmark]
    min_index = benchmark_data[variable].idxmin()
    return benchmark_data.loc[min_index]["Flags"]


def get_o3_config():
    return get_cmd_string_from_config(build_config(all_flags, load_o3_flags(), '-O3'))


def get_multilabel_data(benchmarks, all_flags, average_data):
    X = load_features([b.split('.')[0] for b in benchmarks])
    Y = []

    for benchmark in benchmarks:
        config_str = best_configuration('Energy', benchmark, average_data)
        if config_str == '-O3':
            config_str = get_o3_config()

        labels = []

        config = config_str[4:].split(' ')
        for i, flag in enumerate(config):
            if flag == all_flags[i]:
                labels.append(1) # Flag is turned on
            elif flag == '-fno-' + all_flags[i][2:]:
                labels.append(0) # FLag is turned off -fno
            else:
                print("ERROR:" + flag)

        Y.append(labels)

    Y = np.array(Y)
    
    return X, Y


data = pd.read_csv('CE.results.csv')
data.loc[:, 'Energy'] *= 1e-6 # Convert energy to Joules
data.loc[:, 'Benchmark'] = data['Benchmark'].str.replace('.x', '')

average_data = data.groupby(['Benchmark','Flags', 'Type', 'RunId'], as_index=False).agg({'Energy':'mean', 'Time':'mean'})

all_flags = load_flag_list()
benchmarks = data["Benchmark"].unique()

X, Y = get_multilabel_data(benchmarks, all_flags, average_data)

linear_svc = SVC(C=1.0, kernel='linear')
br = BinaryRelevance(linear_svc)
scores = cross_val_score(br, X, Y, cv=5, n_jobs=-1)
scores
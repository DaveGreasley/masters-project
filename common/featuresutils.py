import pandas as pd

from common.basedirectory import *


def load_feature_frames():
    npb = pd.read_csv(results_dir + '/feature_extractor/NPB/features.csv', index_col=0, header=None)
    spec = pd.read_csv(results_dir + '/feature_extractor/SPEC/features.csv', index_col=0, header=None)
    parboil = pd.read_csv(results_dir + '/feature_extractor/parboil/features.csv', index_col=0, header=None)

    return [npb, spec, parboil], ['NPB', 'SPEC', 'Parboil']


def load_features(benchmarks, with_dwarf=False, with_names=False):
    frames, _ = load_feature_frames()
    combined = pd.concat(frames)
    subset = combined[combined.index.isin(benchmarks)]

    if with_dwarf:
        dwarf_frame = pd.read_csv('dwarf_features.csv', index_col=0)
        dwarf_frame_subset = dwarf_frame[dwarf_frame.index.isin(benchmarks)]
        both = pd.concat([subset, dwarf_frame_subset["Number"]], axis=1)

        if with_names:
            return both.values, both.index.values

        return both.values

    if with_names:
        return subset.values, subset.index.values
    
    return subset.values


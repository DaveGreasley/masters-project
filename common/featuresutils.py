import pandas as pd

def load_feature_frames():
    npb = pd.read_csv('feature_extractor/NPB/features.csv', index_col=0, header=None)
    spec = pd.read_csv('feature_extractor/SPEC/features.csv', index_col=0, header=None)
    parboil = pd.read_csv('feature_extracotr/parboil/features.csv', index_col=0, header=None)

    return [npb, spec, parboil], ['NPB', 'SPEC', 'Parboil']


def load_features(benchmarks, with_dwarf=False):
    frames, _ = load_feature_frames()
    combined = pd.concat(frames)
    subset = combined[combined.index.isin(benchmarks)]

    if with_dwarf:
        dwarf_frame = pd.read_csv('dwarf_features.csv', index_col=0)
        dwarf_frame_subset = dwarf_frame[dwarf_frame.index.isin(benchmarks)]
        return pd.concat([subset, dwarf_frame_subset["Number"]], axis=1).values

    return subset.values


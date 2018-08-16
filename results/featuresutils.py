import pandas as pd


def load_feature_frames():
    npb = pd.read_csv('feature_extractor/NPB/features.csv', index_col=0, header=None)
    spec = pd.read_csv('feature_extractor/SPEC/features.csv', index_col=0, header=None)

    return [npb, spec], ['NPB', 'SPEC']


def load_features(benchmarks):
    frames, _ = load_feature_frames()
    combined = pd.concat(frames)

    return combined[combined.index.isin(benchmarks)].values

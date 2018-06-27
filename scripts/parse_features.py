import sys
import os
import csv


def parse_file(filename):
    with open(filename.rstrip(), mode="r") as features_file:
        features_str = features_file.readline().strip().split(',')
        
        features = []

        for feature in features_str:
            features.append(feature.split('=')[1])

        return features


features_file_name = sys.argv[1]

with open(features_file_name, mode="r") as filenames_file:
    with open("features.csv", mode="a", buffering=1) as features_file:
        wr = csv.writer(features_file)
        for filename in filenames_file:
            features = parse_file(filename)

            wr.writerow(features)



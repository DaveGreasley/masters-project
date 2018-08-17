#!/usr/bin/env python

import argparse
import numpy as np

from common.flagutils import load_flag_list
from common.flagutils import build_config
from common.flagutils import get_cmd_string_from_config

all_flags = load_flag_list()


def generate(num, output):
    with open(output, mode='w', buffering=1) as output_file:
        for i in range(num):
            base_flag = np.random.choice(['-O1', '-O2', '-O3'])
            enabled_flags = np.random.choice(all_flags, np.random.randint(len(all_flags)))
            config = build_config(all_flags, enabled_flags, base_flag)
            output_file.write(get_cmd_string_from_config(config) + '\n')


def main():
    parser = argparse.ArgumentParser(description='Generate GCC optimisation configurations.')
    parser.add_argument('--num', type=int, required=True, help="The number of configurations to generate.")
    parser.add_argument('--output', type=str, required=True, help="The output file to write the configurations to.")
    args = parser.parse_args()

    generate(args.num, args.output)

    return 0


if __name__ == '__main__':
    main()

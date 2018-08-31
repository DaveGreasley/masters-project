import io
import numpy as np

from common.basedirectory import *


def load_flag_list():
    with io.open(base_dir + '/gcc_flags_all.csv') as flag_file:
        next(flag_file)
        return [f.rstrip() for f in flag_file]


def load_o3_flags():
    with io.open(base_dir + '/o3_flags.csv') as flag_file:
        next(flag_file)
        return [f.rstrip() for f in flag_file]


def build_config(all_flags, enabled_flags, base_flag=''):
    config = []
    if base_flag != '':
        config.append(base_flag)

    for f in enabled_flags:
        assert f in all_flags

    for f in all_flags:
        if f in enabled_flags:
            config.append(f)
        else:
            config.append('-fno-' + f[2:])
    return config


def get_cmd_string_from_config(config):
    return ' '.join(config)


def get_o3_config():
    all_flags = load_flag_list()
    return get_cmd_string_from_config(build_config(all_flags, load_o3_flags(), '-O3'))


def remove_static_labels(y, with_labels=False):
    '''Removes any columns that are the same for all samples'''
    all_flags = load_flag_list()

    cols_to_remove = []
    remaining_labels = []
    for i in range(y.shape[1]):
        unique, counts = np.unique(y[:, i], return_counts=True)

        if (len(unique) == 1) or (1 in counts):
            cols_to_remove.append(i)
        else:
            remaining_labels.append(all_flags[i])

    if with_labels:
        return np.delete(y, cols_to_remove, axis=1), np.array(remaining_labels).reshape(1, -1)

    return np.delete(y, cols_to_remove, axis=1)

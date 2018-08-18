import io

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


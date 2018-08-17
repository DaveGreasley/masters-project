import io

from common.basedirectory import *


def load_flag_list():
    with io.open(base_dir + '/gcc_flags_all.csv') as flag_file:
        next(flag_file)
        return [f.rstrip() for f in flag_file]

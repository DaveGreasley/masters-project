# This script will move all benchmarks to a temporary directory and change paths so builds work
# This simply needs to be included after basedirectory.py
# it will also attempt to clean up the dir on exit

import common.basedirectory as basedirectory
import tempfile
import distutils.dir_util as dir_util
import atexit
import os

# Create temp directory
_temp_dir = tempfile.mkdtemp()


# Cleanup directory automatically on exit
def exit_handler():
    if os.path.isdir(_temp_dir):
        dir_util.remove_tree(_temp_dir)


atexit.register(exit_handler)


# Copy benchmark directory recursively
dir_util.copy_tree(basedirectory.base_dir + "/benchmarks", _temp_dir)


# Change directory variables to use temp locations
basedirectory.npb_dir = _temp_dir + "/NPB3.3-OMP"
basedirectory.spec_dir = _temp_dir + "/spec_omp2012"
basedirectory.parboil_dir = _temp_dir + "/parboil"
basedirectory.rodinia_dir = _temp_dir + "/rodinia"

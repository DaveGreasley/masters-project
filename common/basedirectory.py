import os

curr_dir = os.getcwd()
base_dir = curr_dir.split('masters-project')[0] + 'masters-project'

results_dir = base_dir + "/results"
npb_dir = base_dir + "/benchmarks/NPB3.3-OMP"
spec_dir = base_dir + "/benchmarks/spec_omp2012"
energy_monitor_dir = base_dir + "/energy-monitor"

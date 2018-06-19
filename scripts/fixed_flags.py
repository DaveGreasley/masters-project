import os
from subprocess import call, Popen, PIPE

flags = ["-O0", "-O1", "-O2", "-O3"]

base_dir = "../benchmarks/NPB3.3-OMP"
config_dir = base_dir + "/config"
bin_dir = base_dir + "/bin"

samples = 3

with open("fixed_flags_results.csv", "a") as results_file:
    for flag in flags:

        os.environ['COMPILE_FLAGS'] = flag

        call(["make", "suite", "-C", base_dir])

        for benchmark in os.listdir(bin_dir):
            for i in range(0, samples):
                p = Popen(["../energy-monitor/energy-monitor", bin_dir + "/" + benchmark], stdout=PIPE)
                result = p.stdout.read().decode("utf-8")
                energy = int(result.split(",")[0])
                time = float(result.split(",")[1])

                output = benchmark + "," + flag + "," + str(energy) + "," + str(time) + "\n"
                results_file.write(output)

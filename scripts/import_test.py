#!/usr/bin/env python

import subprocess
from subprocess import call, Popen, PIPE

namespace = []
direct = []


for i in range(10):
    p = subprocess.Popen(['sleep', '10'], stdout=subprocess.PIPE)
    result = p.stdout.read().decode("utf-8")
    energy = int(result.split(",")[0])
    time = float(result.split(",")[1])

    namespace.append((energy, time))


for i in range(10):
    p = Popen(['sleep', '10'], stdout=subprocess.PIPE)
    result = p.stdout.read().decode("utf-8")
    energy = int(result.split(",")[0])
    time = float(result.split(",")[1])

    direct.append((energy, time))


namespace_energy_mean = sum(x[0] for x in namespace)/len(namespace)
namespace_time_mean = sum(x[1] for x in namespace)/len(namespace)

direct_energy_mean = sum(x[0] for x in direct)/len(direct)
direct_time_mean = sum(x[1] for x in direct)/len(direct)


print("Namespace call")
print(f"Mean Time: {namespace_time_mean}")
print(f"Mean Energy: {namespace_energy_mean}")
print("")
print("Direct call")
print(f"Mean Time: {direct_time_mean}")
print(f"Mean Energy: {direct_energy_mean}")
print("")

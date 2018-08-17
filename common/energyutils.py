import tempfile
from subprocess import Popen

def measure(energy_monitor_command):
    with tempfile.SpooledTemporaryFile(max_size=1000, mode='r+') as temp_file:
        with Popen(energy_monitor_command, stdout=temp_file) as p:
            p.wait()
        temp_file.seek(0)
        output = temp_file.read()
        energy = int(output.split(",")[0])
        time = float(output.split(",")[1])
        return energy, time

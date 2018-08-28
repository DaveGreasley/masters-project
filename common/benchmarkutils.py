from common.basedirectory import *
from common.model import NPB
from common.model import SPEC
from common.model import Parboil

def get_available_benchmarks():
    return [
        NPB('BT', 'C', npb_dir),
        #NPB('BT', 'C', npb_dir, version='VEC'),
        NPB('CG', 'C', npb_dir),
        NPB('EP', 'D', npb_dir),
        NPB('FT', 'C', npb_dir),
        NPB('IS', 'D', npb_dir),
        NPB('LU', 'C', npb_dir),
        #NPB('LU', 'C', npb_dir, version='VEC'),
        NPB('MG', 'D', npb_dir),
        NPB('SP', 'C', npb_dir),
        NPB('UA', 'C', npb_dir),
        SPEC('botsalgn', spec_dir),
        SPEC('botsspar', spec_dir),
        SPEC('bwaves', spec_dir),
        SPEC('fma3d', spec_dir),
        SPEC('ilbdc', spec_dir),
        SPEC('kdtree', spec_dir),
        SPEC('md', spec_dir),
        SPEC('nab', spec_dir),
        SPEC('imagick', spec_dir),
        SPEC('smithwa', spec_dir),
        SPEC('swim', spec_dir),
        Parboil('tpacf', 'small', parboil_dir),
        Parboil('stencil', 'default', parboil_dir),
        Parboil('lbm', 'long', parboil_dir),
        Parboil('bfs', '1M', parboil_dir),
        Parboil('histo', 'medium', parboil_dir),
        Parboil('mri-gridding', 'smaller', parboil_dir)
    ]


def get_benchmark(name):
    for benchmark in get_available_benchmarks():
        if benchmark.name == name.split('.')[0]:
            return benchmark

    print("Uknown benchmark")
    exit()

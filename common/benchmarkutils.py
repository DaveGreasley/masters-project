import common.basedirectory as basedirectory

from common.model import NPB
from common.model import SPEC
from common.model import Parboil
from common.model import Rodinia

def get_available_benchmarks():
    return [
        NPB('BT', 'C', basedirectory.npb_dir),
        #NPB('BT', 'C', basedirectory.npb_dir, version='VEC'),
        NPB('CG', 'C', basedirectory.npb_dir),
        NPB('EP', 'D', basedirectory.npb_dir),
        NPB('FT', 'C', basedirectory.npb_dir),
        NPB('IS', 'D', basedirectory.npb_dir),
        NPB('LU', 'C', basedirectory.npb_dir),
        #NPB('LU', 'C', basedirectory.npb_dir, version='VEC'),
        NPB('MG', 'D', basedirectory.npb_dir),
        NPB('SP', 'C', basedirectory.npb_dir),
        NPB('UA', 'C', basedirectory.npb_dir),
        SPEC('botsalgn', basedirectory.spec_dir),
        SPEC('botsspar', basedirectory.spec_dir),
        SPEC('bwaves', basedirectory.spec_dir),
        SPEC('fma3d', basedirectory.spec_dir),
        SPEC('ilbdc', basedirectory.spec_dir),
        SPEC('kdtree', basedirectory.spec_dir),
        SPEC('md', basedirectory.spec_dir),
        SPEC('nab', basedirectory.spec_dir),
        SPEC('imagick', basedirectory.spec_dir),
        SPEC('smithwa', basedirectory.spec_dir),
        SPEC('swim', basedirectory.spec_dir),
        Parboil('tpacf', 'small', basedirectory.parboil_dir),
        Parboil('stencil', 'default', basedirectory.parboil_dir),
        Parboil('lbm', 'long', basedirectory.parboil_dir),
        Parboil('bfs', '1M', basedirectory.parboil_dir),
        Parboil('histo', 'medium', basedirectory.parboil_dir),
        Parboil('mri-gridding', 'smaller', basedirectory.parboil_dir),
        Rodinia('backprop', basedirectory.rodinia_dir),
        Rodinia('hotspot', basedirectory.rodinia_dir),
        Rodinia('kmeans', basedirectory.rodinia_dir),
        Rodinia('srad', basedirectory.rodinia_dir),
        Rodinia('streamcluster', basedirectory.rodinia_dir)
    ]


def get_benchmark(name):
    for benchmark in get_available_benchmarks():
        if benchmark.name == name.split('.')[0]:
            return benchmark

    print("Uknown benchmark")
    exit()

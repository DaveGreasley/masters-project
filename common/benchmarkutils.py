from common.basedirectory import *
from common.model import NPB
from common.model import SPEC


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
        SPEC('swim', spec_dir)
    ]



#!/usr/bin/env python

o0_flags = [
'-faggressive-loop-optimizations',
'-fasynchronous-unwind-tables',
'-fauto-inc-dec',
'-fdce',
'-fdelete-null-pointer-checks',
'-fdse',
'-fearly-inlining',
'-ffunction-cse',
'-fgcse-lm',
'-finline',
'-finline-atomics',
'-fira-hoist-pressure',
'-fira-share-save-slots',
'-fira-share-spill-slots',
'-fivopts',
'-fjump-tables',
'-fpeephole',
'-fplt',
'-fprefetch-loop-arrays',
'-fprintf-return-value',
'-frename-registers',
'-frtti',
'-fsched-critical-path-heuristic',
'-fsched-dep-count-heuristic',
'-fsched-group-heuristic',
'-fsched-interblock',
'-fsched-last-insn-heuristic',
'-fsched-rank-heuristic',
'-fsched-spec',
'-fsched-spec-insn-heuristic',
'-fsched-stalled-insns-dep',
'-fschedule-fusion',
'-fshort-enums',
'-fshrink-wrap-separate',
'-fsplit-ivs-in-unroller',
'-fssa-backprop',
'-fstdarg-opt',
'-fstrict-volatile-bitfields',
'-fno-threadsafe-statics',
'-ftree-cselim',
'-ftree-forwprop',
'-ftree-loop-if-convert',
'-ftree-loop-im',
'-ftree-loop-ivcanon',
'-ftree-loop-optimize',
'-ftree-phiprop',
'-ftree-reassoc',
'-ftree-scev-cprop',
'-fvar-tracking',
'-fvar-tracking-assignments',
'-fweb'
]
o1_flags = o0_flags + [
'-fbranch-count-reg',
'-fcombine-stack-adjustments',
'-fcompare-elim',
'-fcprop-registers',
'-fdefer-pop',
'-fforward-propagate',
'-fguess-branch-probability',
'-fif-conversion',
'-fif-conversion2',
'-finline-functions-called-once',
'-fipa-profile',
'-fipa-pure-const',
'-fipa-reference',
'-fmove-loop-invariants',
'-freorder-blocks',
'-fshrink-wrap',
'-fsplit-wide-types',
'-fssa-phiopt',
'-ftree-bit-ccp',
'-ftree-builtin-call-dce',
'-ftree-ccp',
'-ftree-ch',
'-ftree-coalesce-vars',
'-ftree-copy-prop',
'-ftree-dce',
'-ftree-dominator-opts',
'-ftree-dse',
'-ftree-fre',
'-ftree-pta',
'-ftree-sink',
'-ftree-slsr',
'-ftree-sra',
'-ftree-ter'
]
o2_flags = o1_flags + [
'-falign-functions',
'-falign-jumps',
'-falign-labels',
'-falign-loops',
'-fcaller-saves',
'-fcode-hoisting',
'-fcrossjumping',
'-fcse-follow-jumps',
'-fdevirtualize',
'-fdevirtualize-speculatively',
'-fexpensive-optimizations',
'-fgcse',
'-fhoist-adjacent-loads',
'-findirect-inlining',
'-finline-small-functions',
'-fipa-bit-cp',
'-fipa-cp',
'-fipa-icf',
'-fipa-icf-functions',
'-fipa-icf-variables',
'-fipa-ra',
'-fipa-sra',
'-fipa-vrp',
'-fisolate-erroneous-paths-dereference',
'-flra-remat',
'-foptimize-sibling-calls',
'-foptimize-strlen',
'-fpartial-inlining',
'-fpeephole2',
'-freorder-blocks-and-partition',
'-freorder-functions',
'-frerun-cse-after-loop',
'-fschedule-insns2',
'-fstore-merging',
'-fstrict-overflow',
'-fthread-jumps',
'-ftree-pre',
'-ftree-switch-conversion',
'-ftree-tail-merge',
'-ftree-vrp'
]
o3_flags = o2_flags + [
'-fgcse-after-reload',
'-finline-functions',
'-fipa-cp-clone',
'-fpeel-loops',
'-fpredictive-commoning',
'-fsplit-loops',
'-fsplit-paths',
'-ftree-loop-distribute-patterns',
'-ftree-loop-vectorize',
'-ftree-partial-pre',
'-ftree-slp-vectorize',
'-funswitch-loops'
]

def get_base_flags(base_flag):
    base_flags = o0_flags
    if base_flag == '-O1':
        base_flags = o1_flags
    elif base_flag == '-O2':
        base_flags = o2_flags
    elif base_flag == '-O3':
        base_flags = o3_flags
    else:
        print("Base flag not recognised")
        raise

    return base_flags


def shorten_configuration(base_flag, long_config):
    base_flags = get_base_flags(base_flag)

    long_flags = long_config.split(' ')
    short_flags = [f for f in long_flags if not f in base_flags]
    return base_flag + ' ' + ' '.join(short_flags)


test_configuration = "-faggressive-loop-optimizations -falign-functions -falign-jumps -falign-labels -falign-loops -fasynchronous-unwind-tables -fauto-inc-dec -fbranch-count-reg -fbranch-target-load-optimize -fbranch-target-load-optimize2 -fbtr-bb-exclusive -fcaller-saves -fcode-hoisting -fcombine-stack-adjustments -fcompare-elim -fconserve-stack -fcprop-registers -fcrossjumping -fcse-follow-jumps -fdce -fdefer-pop -fdelayed-branch -fdelete-dead-exceptions -fdelete-null-pointer-checks -fdevirtualize -fdevirtualize-speculatively -fdse -fearly-inlining -fexceptions -fexpensive-optimizations -fforward-propagate -ffunction-cse -fgcse -fgcse-after-reload -fgcse-las -fgcse-lm -fgcse-sm -fgraphite -fgraphite-identity -fguess-branch-probability -fhoist-adjacent-loads -fif-conversion -fif-conversion2 -findirect-inlining -finline -finline-atomics -finline-functions -finline-functions-called-once -finline-small-functions -fipa-bit-cp -fipa-cp -fipa-cp-clone -fipa-icf -fipa-icf-functions -fipa-icf-variables -fipa-profile -fipa-pta -fipa-pure-const -fipa-ra -fipa-reference -fipa-sra -fipa-vrp -fira-hoist-pressure -fira-loop-pressure -fira-share-save-slots -fira-share-spill-slots -fisolate-erroneous-paths-attribute -fisolate-erroneous-paths-dereference -fivopts -fjump-tables -fkeep-gc-roots-live -flimit-function-alignment -flive-range-shrinkage -floop-nest-optimize -floop-parallelize-all -flra-remat -fmodulo-sched -fmodulo-sched-allow-regmoves -fmove-loop-invariants -fnon-call-exceptions -fnothrow-opt -fomit-frame-pointer -fopt-info -foptimize-sibling-calls -foptimize-strlen -fpack-struct -fpartial-inlining -fpeel-loops -fpeephole -fpeephole2 -fplt -fpredictive-commoning -fprefetch-loop-arrays -fprintf-return-value -freg-struct-return -frename-registers -freorder-blocks -freorder-blocks-and-partition -freorder-functions -frerun-cse-after-loop -freschedule-modulo-scheduled-loops -frtti -fsched-critical-path-heuristic -fsched-dep-count-heuristic -fsched-group-heuristic -fsched-interblock -fsched-last-insn-heuristic -fsched-pressure -fsched-rank-heuristic -fsched-spec -fsched-spec-insn-heuristic -fsched-spec-load -fsched-spec-load-dangerous -fsched-stalled-insns -fsched-stalled-insns-dep -fsched2-use-superblocks -fschedule-fusion -fschedule-insns -fschedule-insns2 -fsel-sched-pipelining -fsel-sched-pipelining-outer-loops -fsel-sched-reschedule-pipelined -fselective-scheduling -fselective-scheduling2 -fshort-enums -fshort-wchar -fshrink-wrap -fshrink-wrap-separate -fsplit-ivs-in-unroller -fsplit-loops -fsplit-paths -fsplit-wide-types -fssa-backprop -fssa-phiopt -fstack-protector -fstack-protector-all -fstack-protector-explicit -fstack-protector-strong -fstdarg-opt -fstore-merging -fstrict-enums -fstrict-overflow -fstrict-volatile-bitfields -fthread-jumps -fno-threadsafe-statics -ftracer -ftrapv -ftree-bit-ccp -ftree-builtin-call-dce -ftree-ccp -ftree-ch -ftree-coalesce-vars -ftree-copy-prop -fno-tree-cselim -fno-tree-dce -ftree-dominator-opts -ftree-dse -ftree-forwprop -ftree-fre -ftree-loop-distribute-patterns -ftree-loop-distribution -ftree-loop-if-convert -ftree-loop-im -ftree-loop-ivcanon -ftree-loop-optimize -ftree-loop-vectorize -ftree-lrs -ftree-partial-pre -ftree-phiprop -ftree-pre -ftree-pta -ftree-reassoc -ftree-scev-cprop -ftree-sink -ftree-slp-vectorize -ftree-slsr -ftree-sra -ftree-switch-conversion -ftree-tail-merge -ftree-ter -ftree-vectorize -ftree-vrp -funconstrained-commons -funroll-all-loops -funroll-loops -funswitch-loops -funwind-tables -fvar-tracking -fvar-tracking-assignments -fvar-tracking-assignments-toggle -fvar-tracking-uninit -fvariable-expansion-in-unroller -fweb -fwrapv"
print(shorten_configuration('-O3', test_configuration))
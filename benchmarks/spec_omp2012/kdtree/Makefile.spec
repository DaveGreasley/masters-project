TUNE=base
EXT=x
NUMBER=376
NAME=kdtree
SOURCES= kdtree.cc specrand.c
EXEBASE=kdtree
NEED_MATH=
BENCHLANG=CXX
ONESTEP=
CXXONESTEP=

CC               = gcc
CXX              = g++
FC               = gfortran
FOPTIMIZE        = -fno-strict-aliasing -fno-range-check
FPBASE           = yes
OPTIMIZE         = $(COMPILE_OPTIONS) -fopenmp
OS               = unix
absolutely_no_locking = 0
abstol           = 
action           = validate
allow_extension_override = 0
backup_config    = 1
baseexe          = kdtree
basepeak         = 0
benchdir         = benchspec
benchmark        = 376.kdtree
binary           = 
bindir           = exe
build_in_build_dir = 1
builddir         = build
bundleaction     = 
bundlename       = 
calctol          = 0
changedmd5       = 0
check_integrity  = 1
check_md5        = 1
check_version    = 1
clean_between_builds = no
command_add_redirect = 0
commanderrfile   = speccmds.err
commandexe       = kdtree_base.x
commandfile      = speccmds.cmd
commandoutfile   = speccmds.out
commandstdoutfile = speccmds.stdout
compareerrfile   = compare.err
comparefile      = compare.cmd
compareoutfile   = compare.out
comparestdoutfile = compare.stdout
compile_error    = 0
compwhite        = 
configdir        = config
configpath       = /home/dave/Documents/project/benchmarks/omp2012-1.0/config/blue_crystal.cfg
copies           = 1
current_range    = 
datadir          = data
default_size     = ref
delay            = 0
deletebinaries   = 0
deletework       = 0
dependent_workloads = 0
device           = 
difflines        = 10
dirprot          = 511
discard_power_samples = 1
display_order    = 1a
endian           = 12345678
env_vars         = 0
exitvals         = spec_exit
expand_notes     = 0
expid            = 
ext              = x
fake             = 1
feedback         = 1
flag_url_base    = http://www.spec.org/auto/omp2012/flags/
floatcompare     = 
help             = 0
http_proxy       = 
http_timeout     = 30
hw_cpu           = Intel(R) Xeon(R) CPU E5-2680 v4 @ 2.40GHz processor
hw_cpu_mhz       = 2400
hw_cpu_name      = Intel Core i7-6700HQ
hw_disk          = 118 GB  add more disk info here
hw_memory        = 260 GB
hw_memory001     = 9.757 GB fixme: If using DDR3, format is:
hw_memory002     = 'N GB (M x N GB nRxn PCn-nnnnnR-n, ECC)'
hw_model         = Blue Crystal Phase 4
hw_nchips        = 1
hw_ncores        = 28
hw_ncoresperchip = 14
hw_nthreadspercore = 1
hw_vendor        = 
idle_current_range = 
idledelay        = 10
idleduration     = 60
ignore_errors    = 0
ignore_sigint    = 0
ignorecase       = 
info_wrap_columns = 50
inputdir         = input
iteration        = -1
iterations       = 1
keeptmp          = 0
license_num      = 3869
line_width       = 0
locking          = 1
log              = OMP2012
log_line_width   = 0
log_timestamp    = 0
logname          = /home/dave/Documents/project/benchmarks/omp2012-1.0/result/OMP2012.037.log
lognum           = 037
mach             = default
mail_reports     = all
mailcompress     = 0
mailmethod       = smtp
mailport         = 25
mailserver       = 127.0.0.1
mailto           = 
make             = specmake
make_no_clobber  = 0
makeflags        = 
max_active_compares = 0
max_average_uncertainty = 1
max_hum_limit    = 0
max_unknown_uncertainty = 1
mean_anyway      = 0
meter_connect_timeout = 30
meter_errors_default = 0.1
meter_errors_percentage = 0.1
min_report_runs  = 3
min_temp_limit   = 20
minimize_builddirs = 0
minimize_rundirs = 0
name             = kdtree
need_math        = 
no_input_handler = close
no_monitor       = 
note_preenv      = 0
notes_plat_sysinfo_000 =  Sysinfo program /home/dave/Documents/project/benchmarks/omp2012-1.0/Docs/sysinfo
notes_plat_sysinfo_005 =  $Rev: 395 $ $Date:: 2012-07-25 \#$ 8f8c0fe9e19c658963a1e67685e50647
notes_plat_sysinfo_010 =  running on dave-VirtualBox Thu Jul 12 13:21:59 2018
notes_plat_sysinfo_015 = 
notes_plat_sysinfo_020 =  This section contains SUT (System Under Test) info as seen by
notes_plat_sysinfo_025 =  some common utilities.  To remove or add to this section, see:
notes_plat_sysinfo_030 =    http://www.spec.org/omp2012/Docs/config.html\#sysinfo
notes_plat_sysinfo_035 = 
notes_plat_sysinfo_040 =  From /proc/cpuinfo
notes_plat_sysinfo_045 =     model name : Intel(R) Core(TM) i7-6700HQ CPU @ 2.60GHz
notes_plat_sysinfo_050 =        1 "physical id"s (chips)
notes_plat_sysinfo_055 =        2 "processors"
notes_plat_sysinfo_060 =     cores, siblings (Caution: counting these is hw and system dependent.  The
notes_plat_sysinfo_065 =     following excerpts from /proc/cpuinfo might not be reliable.  Use with
notes_plat_sysinfo_070 =     caution.)
notes_plat_sysinfo_075 =        cpu cores : 2
notes_plat_sysinfo_080 =        siblings  : 2
notes_plat_sysinfo_085 =        physical 0: cores 0 1
notes_plat_sysinfo_090 =     cache size : 6144 KB
notes_plat_sysinfo_095 = 
notes_plat_sysinfo_100 =  From /proc/meminfo
notes_plat_sysinfo_105 =     MemTotal:       10230904 kB
notes_plat_sysinfo_110 =     HugePages_Total:       0
notes_plat_sysinfo_115 =     Hugepagesize:       2048 kB
notes_plat_sysinfo_120 = 
notes_plat_sysinfo_125 =  /usr/bin/lsb_release -d
notes_plat_sysinfo_130 =     Ubuntu 17.10
notes_plat_sysinfo_135 = 
notes_plat_sysinfo_140 =  From /etc/*release* /etc/*version*
notes_plat_sysinfo_145 =     debian_version: stretch/sid
notes_plat_sysinfo_150 =     os-release:
notes_plat_sysinfo_155 =        NAME="Ubuntu"
notes_plat_sysinfo_160 =        VERSION="17.10 (Artful Aardvark)"
notes_plat_sysinfo_165 =        ID=ubuntu
notes_plat_sysinfo_170 =        ID_LIKE=debian
notes_plat_sysinfo_175 =        PRETTY_NAME="Ubuntu 17.10"
notes_plat_sysinfo_180 =        VERSION_ID="17.10"
notes_plat_sysinfo_185 =        HOME_URL="https://www.ubuntu.com/"
notes_plat_sysinfo_190 =        SUPPORT_URL="https://help.ubuntu.com/"
notes_plat_sysinfo_195 = 
notes_plat_sysinfo_200 =  uname -a:
notes_plat_sysinfo_205 =     Linux dave-VirtualBox 4.13.0-46-generic \#51-Ubuntu SMP Tue Jun 12 12:36:29
notes_plat_sysinfo_210 =     UTC 2018 x86_64 x86_64 x86_64 GNU/Linux
notes_plat_sysinfo_215 = 
notes_plat_sysinfo_220 =  run-level 5 Jul 11 12:30
notes_plat_sysinfo_225 = 
notes_plat_sysinfo_230 =  SPEC is set to: /home/dave/Documents/project/benchmarks/omp2012-1.0
notes_plat_sysinfo_235 =     Filesystem     Type  Size  Used Avail Use% Mounted on
notes_plat_sysinfo_240 =     /dev/sda1      ext4  118G   32G   81G  28% /
notes_plat_sysinfo_245 = 
notes_plat_sysinfo_250 =  Additional information from dmidecode:
notes_plat_sysinfo_255 = 
notes_plat_sysinfo_260 =  (End of data from sysinfo program)
notes_wrap_columns = 0
notes_wrap_indent =   
num              = 376
obiwan           = 
os_exe_ext       = 
output           = asc
output_format    = asc
output_root      = 
outputdir        = output
parallel_setup   = 1
parallel_setup_prefork = 
parallel_setup_type = fork
parallel_test    = 0
parallel_test_submit = 0
parallel_test_workloads = 
path             = /home/dave/Documents/project/benchmarks/omp2012-1.0/benchspec/OMP2012/376.kdtree
plain_train      = 0
platform         = 
power            = 0
preenv           = 1
prefix           = 
prepared_by      = dave  (is never output, only tags rawfile)
ranks            = -1
rate             = 0
realuser         = your name here
rebuild          = 1
reftime          = reftime
reltol           = 
reportable       = 0
resultdir        = result
review           = 0
run              = all
rundir           = run
runspec          = /home/dave/Documents/project/benchmarks/omp2012-1.0/bin/runspec --config=blue_crystal.cfg --fake --size train gross --iterations 1
safe_eval        = 1
section_specifier_fatal = 1
sendmail         = /usr/sbin/sendmail
setpgrp_enabled  = 1
setprocgroup     = 1
setup_error      = 0
shrate           = 0
sigint           = 2
size             = train
size_class       = train
skipabstol       = 
skipobiwan       = 
skipreltol       = 
skiptol          = 
smarttune        = base
specdiff         = specdiff
specmake         = Makefile.YYYtArGeTYYYspec
specrun          = specinvoke
speed            = 0
srcalt           = 
srcdir           = src
srcsource        = /home/dave/Documents/project/benchmarks/omp2012-1.0/benchspec/OMP2012/376.kdtree/src
stagger          = 10
strict_rundir_verify = 1
sw_compiler      = Computer System Compiler C and Fortran90
sw_file          = ext4
sw_os            = CentOS Linux release 7.3.1611 (Core)
sw_os001         = Ubuntu 17.10
sw_os002         = 4.13.0-46-generic
sw_state         = Run level 5 (add definition here)
sysinfo_program  = specperl /home/dave/Documents/project/benchmarks/omp2012-1.0/Docs/sysinfo
table            = 0
teeout           = 1
teerunout        = yes
test_date        = Jul-2018
threads          = -1
top              = /home/dave/Documents/project/benchmarks/omp2012-1.0
train_with       = train
tune             = base
uid              = 1000
unbuffer         = 1
uncertainty_exception = 5
update-flags     = 0
use_submit_for_speed = 1
username         = dave
vendor           = anon
vendor_makefiles = 0
verbose          = 5
version          = 20
version_url      = http://www.spec.org/auto/omp2012/current_version
voltage_range    = 
worklist         = list
OUTPUT_RMFILES   = trainset.out

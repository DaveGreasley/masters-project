#define _GNU_SOURCE 

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <stdbool.h>
#include <unistd.h>
#include <sys/sysinfo.h>
#include <sched.h>
#include <argp.h>

// Holds command line arguments
struct arguments
{
    char *command, *out_file;
};

// Should we perform DRAM measurements
bool dram_domain_available;

// Sample rate in Hz
const float sample_rate = 100;

// The cpu package sysfs energy_uj value resets at this value
const long long pkg_energy_max_value = 262143328850;

// The dram sysfs energy_uj value resets at this value
const long long dram_energy_max_value = 65712999613;

// The energy consumed by the launched program
long long energy_uj = 0;

// The runtime of the benchmark
double runtime = 0;

// The number of times the pkg and dram counters over flow
int num_pkg_overflows = 0;
int num_dram_overflows = 0;

// The measurements this script supports
enum Measurement { PKG = 0, DRAM = 1 };

// The number of packages (sockets) available on the current machine
int total_packages=0;

static struct argp_option options[] =
{
    {"command", 'c', "\"./your-command\"", 0, "The command to run and measure"},
    {"output", 'o', "energy-monitor.out", 0, "The name of the file to redirect command output to"},
    {0}
};

static error_t
parse_opt (int key, char *arg, struct argp_state *state)
{
    struct arguments *arguments = state->input;
    
    switch (key)
    {
        case 'c':
            arguments->command = arg;
            break;
        case 'o':
            arguments->out_file = arg;
            break;
        default:
            return ARGP_ERR_UNKNOWN;
    }
    
    return 0;
}

// ARGP struct
static struct argp argp = {options, parse_opt, 0, 0};

double get_timestamp()
{
    struct timeval tv;
    gettimeofday(&tv, NULL);
    return tv.tv_sec + tv.tv_usec*1e-6;
}

long long get_energy(enum Measurement measurement)
{
    if (measurement == DRAM && !dram_domain_available)
        return 0;

    int i = 0;
    char filename[100];
    long long value = 0;
    long long value_total = 0;

    for (i=0;i<total_packages;i++)
    {
        if (measurement == PKG)
        {
            sprintf(filename, "/sys/class/powercap/intel-rapl/intel-rapl:%d/energy_uj", i);
        } 
        else 
        {
            sprintf(filename, "/sys/class/powercap/intel-rapl/intel-rapl:%d/intel-rapl:%d:0/energy_uj", i, i);
        }

        FILE *fff = fopen(filename, "r");
        if (fff==NULL)
        {
            printf("Error: Cannot access RAPL counters (%d)\n", measurement);
        }
        else
        {
            fscanf(fff, "%lld", &value);
            fclose(fff);
        }

        value_total += value;
    }

    return value_total;
}

long long check_overflow(enum Measurement measurement, long long start, long long end)
{
    if (start < end)
        return end - start;

    long long max_value;
    if (measurement == PKG)
    {
        max_value = pkg_energy_max_value;
    }
    else
    {
        max_value = dram_energy_max_value;
    }

    return max_value - start + end;
}

void run_and_measure(struct arguments arguments)
{
    printf("test");
    char *command = "";
    strcat(command, arguments.command);
    strcat(command, "> ");
    strcat(command, arguments.out_file);

    printf("test2");

    double start_time = get_timestamp();
    long long start_energy_pkg = get_energy(PKG);
    long long start_energy_dram = get_energy(DRAM);
    
    system(arguments.command);
    
    double end_time = get_timestamp();
    long long end_energy_pkg = get_energy(PKG);
    long long end_energy_dram = get_energy(DRAM);

    runtime =  end_time - start_time;
    
    
    energy_uj += check_overflow(PKG, start_energy_pkg, end_energy_pkg);
    energy_uj += check_overflow(DRAM, start_energy_dram, end_energy_dram);
}

#define MAX_CPUS	1024
#define MAX_PACKAGES	16

void detect_packages(void)
{
    char filename[BUFSIZ];
    FILE *fff;
    int package;
    int i;
    int package_map[MAX_PACKAGES];

    for(i=0;i<MAX_PACKAGES;i++) package_map[i]=-1;

    for(i=0;i<MAX_CPUS;i++) 
    {
        sprintf(filename,"/sys/devices/system/cpu/cpu%d/topology/physical_package_id",i);
        fff=fopen(filename,"r");
        if (fff==NULL) break;
        fscanf(fff,"%d",&package);
        fclose(fff);

        if (package_map[package]==-1) 
        {
            total_packages++;
            package_map[package]=i;
        }
    }
}

void detect_dram_domain()
{
    dram_domain_available = false;
    if (access("/sys/class/powercap/intel-rapl/intel-rapl:0/intel-rapl:0:0/energy_uj", F_OK) != -1)
    {
        dram_domain_available = true;
    }
}

int main(int argc, char *argv[])
{
    printf("main-1");
    struct arguments arguments;

    arguments.command = "";
    arguments.out_file = "";

    printf("main0");

    // Parse command line arguments
    argp_parse (&argp, argc, argv, 0, 0, &arguments);

    if (strlen(arguments.command) == 0)
    {
        printf("You must specifiy a command with -c=\"./your-command\"\n");
        return 1;
    }

    printf("main1");

    detect_packages();
    detect_dram_domain();

    run_and_measure(arguments);

    printf("%lld,%f\n", energy_uj, runtime);

    return 0;
}

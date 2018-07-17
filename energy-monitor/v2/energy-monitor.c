#define _GNU_SOURCE 

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <pthread.h>
#include <stdbool.h>
#include <unistd.h>
#include <sys/sysinfo.h>
#include <sched.h>

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

// The run benchmark command
char command[100];

// The number of packages (sockets) available on the current machine
int total_packages=0;

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

void run_and_measure()
{
    double start_time = get_timestamp();
    long long start_energy_pkg = get_energy(PKG);
    long long start_energy_dram = get_energy(DRAM);
    
    int status = system(command);
    
    double end_time = get_timestamp();
    long long end_energy_pkg = get_energy(PKG);
    long long end_energy_dram = get_energy(DRAM);

    runtime =  end_time - start_time;
    energy_uj += end_energy_pkg - start_energy_pkg;
    energy_uj += end_energy_dram - start_energy_dram;
}

void get_command(int argc, char *argv[])
{
    int i;

    for (i = 1; i < argc; i = i +1)
    {
        strcat(command, argv[i]);
        strcat(command, " ");
    }

    strcat(command, "> energy-monitor.out");
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
    if (argc <= 1)
    {
        printf("You must provide an executable to monitor\n");
        exit(1);
    }

    detect_packages();
    detect_dram_domain();
    get_command(argc, argv);

    run_and_measure();

    printf("%lld,%f\n", energy_uj, runtime);

    return 0;
}

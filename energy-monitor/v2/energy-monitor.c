#define _GNU_SOURCE 

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <pthread.h>
#include <stdbool.h>
#include <unistd.h>
#include <sys/sysinfo.h>
#include <sched.h>


bool benchmark_complete;
bool dram_domain_available;

pthread_t measure_thread;

// Sample rate in Hz
const float sample_rate = 100;

// The cpu package sysfs energy_uj value resets at this value
const long long pkg_energy_max_value = 262143328850;

// The dram sysfs energy_uj value resets at this value
const long long dram_energy_max_value = 65712999613;

// The energy consumed by the launched program
long long energy_uj = 0;

// The number of times the pkg and dram counters over flow
int num_pkg_overflows = 0;
int num_dram_overflows = 0;

char command[100];

int total_packages=0;

double get_timestamp()
{
    struct timeval tv;
    gettimeofday(&tv, NULL);
    return tv.tv_sec + tv.tv_usec*1e-6;
}

double run_benchmark()
{
    benchmark_complete = false;
    
    double benchmark_start = get_timestamp();
    int status = system(command);
    double benchmark_end = get_timestamp();

    benchmark_complete = true;

    return benchmark_end - benchmark_start;
}

int stick_this_thread_to_last_core() {
    int num_cores = sysconf(_SC_NPROCESSORS_ONLN);

    cpu_set_t cpuset;
    CPU_ZERO(&cpuset);
    CPU_SET(num_cores - 1, &cpuset);

    pthread_t current_thread = pthread_self();    
    return pthread_setaffinity_np(current_thread, sizeof(cpu_set_t), &cpuset);
}

void* measure_energy(void *param)
{
    stick_this_thread_to_last_core();

    long long pkg_previous_value[total_packages];
    long long pkg_current_value [total_packages];
    long long dram_current_value[total_packages];
    long long dram_previous_value[total_packages];
    int i = 0;
    char filename_pkg[100];
    char filename_dram[100];
    for(i=0;i<total_packages;i++) dram_current_value[i]=dram_previous_value[i]=pkg_previous_value[i]=pkg_current_value[i]=-1;

    while(!benchmark_complete)
    {
        for (i=0;i<total_packages;i++)
	    {
		    sprintf(filename_pkg, "/sys/class/powercap/intel-rapl/intel-rapl:%d/energy_uj", i);
		    FILE *fff = fopen(filename_pkg, "r");
		    if (fff==NULL)
		    {
		        printf("Error: Cannot access Package RAPL counters\n");
		    }
		    else
		    {
		        fscanf(fff, "%lld", &pkg_current_value[i]);
		        fclose(fff);
		    }

		    if (pkg_previous_value[i] > -1) 
		    {
		        if (pkg_current_value[i] < pkg_previous_value[i])
		        {
			        // Here we handle the overflow of the sysfs energy_uj measurement 
                    num_pkg_overflows++;
			        energy_uj += (pkg_energy_max_value - pkg_previous_value[i]) + pkg_current_value[i];
		        }
		        else 
		        {
			        energy_uj += pkg_current_value[i] - pkg_previous_value[i];
		        }
		    }

		    pkg_previous_value[i] = pkg_current_value[i];

            if (dram_domain_available)
            {

                sprintf(filename_dram, "/sys/class/powercap/intel-rapl/intel-rapl:%d/intel-rapl:%d:0/energy_uj", i, i);
                fff = fopen(filename_dram, "r");
                if (fff==NULL)
                {
                    printf("Error: Cannot access DRAM RAPL counters\n");
                }
                else
                {
                    fscanf(fff, "%lld", &dram_current_value[i]);
                    fclose(fff);
                }

                if (dram_previous_value[i] > -1) 
                {
                    if (dram_current_value[i] < dram_previous_value[i])
                    {
                        // Here we handle the overflow of the sysfs energy_uj measurement 
                        num_dram_overflows++;
                        energy_uj += (dram_energy_max_value - dram_previous_value[i]) + dram_current_value[i];
                    }
                    else 
                    {
                        energy_uj += dram_current_value[i] - dram_previous_value[i];
                    }
                }

                dram_previous_value[i] = dram_current_value[i];
        
            }
        }

        sleep(1/sample_rate);
    }

    return NULL;
}


void get_command(int argc, char *argv[])
{
    int i;

    for (i = 1; i < argc; i = i +1)
    {
        strcat(command, argv[i]);
        strcat(command, " ");
    }

    strcat(command, "> result");
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

    double execution_time;
    
    detect_packages();
    detect_dram_domain();
    get_command(argc, argv);

    pthread_create(&measure_thread, NULL, measure_energy, NULL);

    execution_time = run_benchmark();

    pthread_join(measure_thread, NULL);

    printf("%lld,%f,%d,%d\n", energy_uj, execution_time,num_pkg_overflows, num_dram_overflows);

    return 0;
}

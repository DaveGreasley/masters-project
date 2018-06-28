#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <pthread.h>
#include <stdbool.h>
#include <unistd.h>
#include <sys/sysinfo.h>

bool benchmark_complete;

pthread_t measure_thread;

// Sample rate in Hz
const float sample_rate = 100;

// The cpu package sysfs energy_uj value resets at this value
const long long pkg_energy_max_value = 262143328850;

// The dram sysfs energy_uj value resets at this value
const long long dram_energy_max_value = 65712999613;

// The energy consumed by the launched program
long long energy_uj = 0;

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

void* measure_energy(void *param)
{
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
			        energy_uj += (pkg_energy_max_value - pkg_previous_value[i]) + pkg_current_value[i];
		        }
		        else 
		        {
			        energy_uj += pkg_current_value[i] - pkg_previous_value[i];
		        }
		    }

		    pkg_previous_value[i] = pkg_current_value[i];

        
		    sprintf(filename_dram, "/sys/class/powercap/intel-rapl/intel-rapl:%d/intel-rapl:%d:0", i, i);
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
			        energy_uj += (dram_energy_max_value - dram_previous_value[i]) + dram_current_value[i];
		        }
		        else 
		        {
			        energy_uj += dram_current_value[i] - dram_previous_value[i];
		        }
		    }

		    dram_previous_value[i] = dram_current_value[i];
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


int main(int argc, char *argv[])
{
    if (argc <= 1)
    {
        printf("You must provide an executable to monitor\n");
        exit(1);
    }

    double execution_time;
    
    detect_packages();
    get_command(argc, argv);

    pthread_create(&measure_thread, NULL, measure_energy, NULL);

    execution_time = run_benchmark();

    pthread_join(measure_thread, NULL);

    printf("%lld,%f\n", energy_uj, execution_time);

    return 0;
}

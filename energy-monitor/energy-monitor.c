#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <pthread.h>
#include <stdbool.h>
#include <unistd.h>
#include <sys/sysinfo.h>

bool benchmark_complete;
pthread_mutex_t mutex = PTHREAD_MUTEX_INITIALIZER;

pthread_t launch_thread;
pthread_t measure_thread;

// Sample rate in Hz
const float sample_rate = 100;

// MSR_PKG_ENERGY_STATUS MSR is a 32 bit integer so this is its max value.
const long long energy_max_value = 2147483647;

// Energy measurement is in micro joules 
const long energy_conversion_factor = 1000000;

char command[100];

int total_packages=0;

double get_timestamp()
{
      struct timeval tv;
      gettimeofday(&tv, NULL);
      return tv.tv_sec + tv.tv_usec*1e-6;
}

void* start_benchmark(void *param)
{
    printf("Starting %s\n", command);

    double benchmark_start = get_timestamp();
    int status = system(command);
    double benchmark_end = get_timestamp();

    pthread_mutex_lock(&mutex);
    benchmark_complete = true;
    pthread_mutex_unlock(&mutex);

    printf("Benchmark complete. Took %lf seconds\n", (benchmark_end-benchmark_start));

    return NULL;
}

void* measure_energy(void *param)
{
    long long energy = 0;
    long long previous_value[total_packages];
    long long current_value [total_packages];
    int i = 0;
    char filename[100];

    for(i=0;i<total_packages;i++) previous_value[i]=current_value[i]=-1;

    printf("Measuring energy.\n");

    while(!benchmark_complete)
    {
        for (i=0;i<total_packages;i++)
	    {
		    sprintf(filename, "/sys/class/powercap/intel-rapl/intel-rapl:%d/energy_uj", i);
		    FILE *fff = fopen(filename, "r");
		    if (fff==NULL)
		    {
		        printf("Error: Cannot access RAPL counters\n");
		    }
		    else
		    {
		        fscanf(fff, "%lld", &current_value[i]);
		        fclose(fff);
		    }

		    if (previous_value[i] > -1) 
		    {
		        if (current_value[i] < previous_value[i])
		        {
			        // Here we handle the overflow of the MSR_PKG_ENERGY_STATUS MSR. Energy is 
			        // stored as a 32bit integer and when this number is exceeded the value is reset
			        // to 0. 
			        energy += (energy_max_value - previous_value[i]) + current_value[i];
		        }
		        else 
		        {
			        energy += current_value[i] - previous_value[i];
		        }
		    }

		    previous_value[i] = current_value[i];
	    }

        sleep(1/sample_rate);
    }

    printf("Used %lld Joules,\n", (energy/energy_conversion_factor));

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

    detect_packages();

    printf("There are %d processors on %d packages\n", get_nprocs(), total_packages);

    get_command(argc, argv);

    benchmark_complete = false;

    pthread_create(&launch_thread, NULL, start_benchmark, NULL);
    pthread_create(&measure_thread, NULL, measure_energy, NULL);

    pthread_join(launch_thread, NULL);
    pthread_join(measure_thread, NULL);

    return 0;
}

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <pthread.h>
#include <stdbool.h>
#include <unistd.h>


bool benchmark_complete;
pthread_mutex_t mutex = PTHREAD_MUTEX_INITIALIZER;

pthread_t launch_thread;
pthread_t measure_thread;

// Sample rate in Hz
const float sample_rate = 100;

// MSR_PKG_ENERGY_STATUS MSR is a 32 bit integer so this is its max value.
const long long energy_max_value = 2147483647;

// Factor to convert energy units into Joules
const long energy_conversion_factor = 15300000;

char command[100];

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
    long long previous_value = -1;
    long long current_value = -1;

    printf("Measuring energy.\n");

    while(!benchmark_complete)
    {
        FILE *fff = fopen("/sys/class/powercap/intel-rapl/intel-rapl:0/energy_uj", "r");
        if (fff==NULL)
        {
            printf("Error: Cannot access RAPL counters\n");
        }
        else
        {
            fscanf(fff, "%lld", &current_value);
            fclose(fff);
        }

        if (previous_value > -1) 
        {
            if (current_value < previous_value)
            {
                // Here we handle the overflow of the MSR_PKG_ENERGY_STATUS MSR. Energy is 
                // stored as a 32bit integer and when this number is exceeded the value is reset
                // to 0. 
                energy += (energy_max_value - previous_value) + current_value;
            }
            else 
            {
                energy += current_value - previous_value;
            }
        }

        previous_value = current_value;

        sleep(1/sample_rate);
    }

    printf("Used %lld Joules,\n", (energy/energy_conversion_factor));

    return NULL;
}


void get_command(int argc, char *argv[])
{
    int i;
    strcat(command, "./");

    for (i = 1; i <= argc; i++)
    {
        strcat(command, argv[i]);
    }
}


int main(int argc, char *argv[])
{
    if (argc <= 1)
    {
        printf("You must provide an executable to monitor\n");
        exit(1);
    }

    get_command(argc, argv);

    benchmark_complete = false;

    pthread_create(&launch_thread, NULL, start_benchmark, NULL);
    pthread_create(&measure_thread, NULL, measure_energy, NULL);

    pthread_join(launch_thread, NULL);
    pthread_join(measure_thread, NULL);

    return 0;
}

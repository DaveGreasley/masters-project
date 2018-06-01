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

char command[100];

void* start_benchmark(void *param)
{
    printf("Starting %s\n", command);

    int status = system(command);

    pthread_mutex_lock(&mutex);
    benchmark_complete = true;
    pthread_mutex_unlock(&mutex);

    printf("Done.\n");

    return NULL;
}

void* measure_energy(void *param)
{
    long long energy = 0;
    long long previous_value = -1;
    long long current_value = -1;

    while(!benchmark_complete)
    {
        printf("Measuring energy.");

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
                // handle overflow
            }
            energy += current_value - previous_value;
        }

        previous_value = current_value;

        sleep(1/sample_rate);
    }
}


char *get_command(char *argv[])
{
    return "./sleep 10";
}


int main(int argc, char *argv[])
{
    if (argc <= 1)
    {
        printf("You must provide an executable to monitor\n");
        exit(1);
    }

    strcpy(command, get_command(argv));

    benchmark_complete = false;

    pthread_create(&launch_thread, NULL, start_benchmark, NULL);
    pthread_create(&measure_thread, NULL, measure_energy, NULL);

    pthread_join(launch_thread, NULL);
    pthread_join(measure_thread, NULL);
}

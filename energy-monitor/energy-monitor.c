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
    while(!benchmark_complete)
    {
        printf("Measuring energy\n");
        sleep(1);
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

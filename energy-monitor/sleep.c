#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>

int main(int argc, char *argv[])
{
    if (argc > 1)
    {
	int time = atoi(argv[1]);
	printf("Sleeping for %d seconds\n", time);
        sleep(time);
    }
    else
    {
	printf("Sleeping for 10 seconds\n");
        sleep(10);
    }

    return 0;
}

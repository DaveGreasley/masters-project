#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>

int main(int argc, char *argv[])
{
    if (argc > 0)
    {
        int time = atoi(argv[1]);
        sleep(time);
    }
    else
    {
        sleep(10);
    }
}

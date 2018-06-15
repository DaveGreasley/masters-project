CC=gcc
CFLAGS=-I -std=c99 -Wall

.PHONY : all clean

all: energy-monitor

energy-monitor:
	$(CC) $(CFLAGS) -pthread energy-monitor.c -o energy-monitor

clean:
	rm -f energy-monitor


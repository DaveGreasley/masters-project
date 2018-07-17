CC=gcc
CFLAGS=-I -std=c99 -Wall

.PHONY : all v1 v2 clean

all: v2

v1: v1/energy-monitor.c
	$(CC) $(CFLAGS) -pthread v1/energy-monitor.c -o energy-monitor.v1

v2: v2/energy-monitor.c
	$(CC) $(CFLAGS) -pthread v2/energy-monitor.c -o energy-monitor

clean:
	rm -f energy-monitor.v1
	rm -f energy-monitor


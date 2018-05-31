CC=gcc
CFLAGS=-I --std=c99 -Wall

.PHONY : all clean

all: energy-monitor sleep

energy-monitor:
	$(CC) -pthread energy-monitor.c -o energy-monitor

sleep:
	$(CC) sleep.c -o sleep


clean:
	rm -f sleep
	rm -f energy-monitor


CC = gcc
CFLAGS = -Wall -std=c99

ex14q1: ex14q1.c ex14q11.c
	$(CC) $(CFLAGS) ex14q1.c ex14q11.c -o $@

clear:
	rm -rf ./ex14q1 Solutions sol*.txt
	clear
	
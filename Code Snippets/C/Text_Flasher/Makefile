all: tester

tester: tester.o flasher.o
	gcc -o tester tester.o flasher.o

tester.o: tester.c flasher.h
	gcc -g -c tester.c

flasher.o: flasher.c
	gcc -g -c flasher.c

clean:
	rm -f *.o
	rm -f tester

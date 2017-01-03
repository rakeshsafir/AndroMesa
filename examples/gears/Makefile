

all:
	gcc -Wall -g -I. -c eglgears.c -o eglgears.o
	gcc -Wall -g -I. -c glxgears.c -o glxgears.o
	gcc -L. -Lmesa/lib eglgears.o -o eglgears -leglut_x11 -lGL -lEGL -lX11 -lm
	gcc -L. -Lmesa/lib glxgears.o -o glxgears -lGL -lX11 -lm

clean:
	rm -f *.o eglgears glxgears

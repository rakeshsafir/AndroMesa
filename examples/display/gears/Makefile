

all: eglut
	gcc -Wall -g -I. -I../../../mesa/include -I../eglut -c eglgears.c -o eglgears.o
	gcc -Wall -g -I. -I../../../mesa/include -I../eglut -c glxgears.c -o glxgears.o
	gcc -L. -L../../../mesa/lib eglgears.o eglut.o eglut_x11.o -o eglgears -leglut_x11 -lGL -lEGL -lX11 -lm
#	gcc -L. -L../../../mesa/lib glxgears.o eglut.o eglut_x11.o -o glxgears -lGL -lX11 -lm


eglut:
	gcc -Wall -g -I. -I../../../mesa/include -I../../eglut -c ../eglut/eglut.c -o eglut.o
	gcc -Wall -g -I. -I../../../mesa/include -I../../eglut -c ../eglut/eglut_x11.c -o eglut_x11.o
	


clean:
	rm -f *.o eglgears glxgears

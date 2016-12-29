all:
	gcc -Wall -g -I. -c eglgears.c -o eglgears.o
	gcc -L. -Lmesa/lib eglgears.o -o eglgears -leglut_x11 -lGL -lEGL -lX11 -lm

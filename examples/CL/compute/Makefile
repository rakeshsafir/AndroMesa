all:
	gcc -c -g -Wall -I/home/linuxdev/Development/Mesa/QtProjects/AndroMesa/build/include -I/home/linuxdev/Development/Mesa/QtProjects/AndroMesa/mesa/include squares.c -o squares.o
#	gcc -L/home/linuxdev/Development/Mesa/QtProjects/AndroMesa/mesa/lib -L/home/linuxdev/Development/Mesa/QtProjects/AndroMesa/mesa/lib/gallium -L/home/linuxdev/Development/Mesa/QtProjects/AndroMesa/mesa/src/gallium/state_trackers/clover/.libs -L/usr/lib/x86_64-linux-gnu squares.o -o squares.exe -lm -lOpenCL
	gcc -L/home/linuxdev/Development/Mesa/QtProjects/AndroMesa/build/lib -L/home/linuxdev/Development/Mesa/QtProjects/AndroMesa/mesa/lib -L/home/linuxdev/Development/Mesa/QtProjects/AndroMesa/mesa/lib/gallium squares.o -o squares.exe  -lelf -lOpenCL

clean:
	rm -f squares.exe squares.o

	

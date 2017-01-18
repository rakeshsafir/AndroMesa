#include <stdio.h>

extern int main_eglgears(int argc, char *argv[]);
extern int main_glxgears(int argc, char *argv[]);


int main( int argc, char *argv[]) {
    printf("[%s:%d] Starting eglgears...\n", __FILE__, __LINE__);
    int ret = -1;

    ret = main_eglgears(argc, argv);

    ret = main_glxgears(argc, argv);

    return ret;
}

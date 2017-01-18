# Makfile to build GL examples
CROSS_COMPILE :=

# Compile Variables
CC		:=$(CROSS_COMPILE)-gcc
CXX		:=$(CROSS_COMPILE)-g++
LINK		:=$(CROSS_COMPILE)-g++
DEFINES		:=-DDEBUG
CFLAGS		:=-Wall -g $(DEFINES)
CXXFLAGS	:=-Wall -g $(DEFINES)
INCFLAGS	:=-I. -I../../eglut
LDFLAGS		:=-L../../../mesa/lib
LIBS		:=-lGL -lEGL -lX11 -lm

# Add Sysroot in case we are cross compiling
ifneq ($(CROSS_COMPILE),)
SYSROOT	:=
CFLAGS		+=--sysroot="$(SYSROOT)"
CFLAGS		+=--sysroot="$(SYSROOT)"
LDFLAGS		+=--sysroot="$(SYSROOT)"
endif

# Build directory
BUILDIR		:=.obj

# EGLUT path
EGLUT_DIR	:=../../eglut

# Source List
SOURCE		:=eglgears.c glxgears.c main.c
SOURCE		+=$(EGLUT_DIR)/eglut.c
SOURCE		+=$(EGLUT_DIR)/eglut_x11.c
OBJECTS		:=$(patsubst %.c, $(BUILDIR)/%.o, $(SOURCE))

TARGET		:=GL

all: PREBUILD $(OBJECTS) $(TARGET) POSTBUILD


$(TARGET): $(OBJECTS)
	$(LINK) $(LDFLAGS) $(OBJECTS) -o $(TARGET).exe $(LIBS)


PREBUILD:
	@mkdir -p $(BUILDIR)

POSTBUILD:
	@cp $(TARGET).exe ../../
	

# Implicit build rule
$(BUILDIR)/%.o: %.c
	@mkdir -p $(@D)
	$(CC) $(CFLAGS) $(INCFLAGS) -c $^ -o $@



clean:
	rm -f "$(TARGET).exe" "$(OBJECTS)"

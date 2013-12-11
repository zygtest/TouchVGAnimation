ROOTDIR     =../../..
TARGET      =libglcanvas.a
SRCS        =$(wildcard *.cpp)
OBJS        =$(SRCS:.cpp=.o)
INSTALL_DIR ?=$(ROOTDIR)/build

CPPFLAGS    += -Wall \
               -I$(ROOTDIR)/core/inc/glcanvas \
               -I$(ROOTDIR)/thirdparty/MonkVG/include/MonkVG \
               -I$(ROOTDIR)/thirdparty/Shape/core/inc/canvas \
               -I$(ROOTDIR)/thirdparty/Shape/core/inc/test

all:        $(TARGET)
$(TARGET):  $(OBJS)
	$(AR) $(ARFLAGS) $@ $(OBJS)

clean:
	@rm -rfv *.o *.a
ifdef touch
	@touch -c *
endif

install:
	@test -d $(INSTALL_DIR) || mkdir $(INSTALL_DIR)
	@! test -e $(TARGET) || cp -v $(TARGET) $(INSTALL_DIR)

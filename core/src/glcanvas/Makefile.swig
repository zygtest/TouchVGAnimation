ROOTDIR  =../../..
PKGNAME  =touchvg
PROJNAME =glcanvas

INCLUDES += -I$(ROOTDIR)/core/inc \
            -I$(ROOTDIR)/core/inc/glcanvas \
            -I$(ROOTDIR)/thirdparty/MonkVG/include/MonkVG \
            -I$(ROOTDIR)/thirdparty/Shape/core/inc/canvas \
            -I$(ROOTDIR)/thirdparty/Shape/core/inc/test

include $(ROOTDIR)/core/mk/config.mk
include $(ROOTDIR)/core/mk/Makefile.swig

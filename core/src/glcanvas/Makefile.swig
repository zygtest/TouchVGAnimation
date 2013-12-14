ROOTDIR  =../../..
PKGNAME  =touchvg
PROJNAME =glcanvas

INCLUDES += -I$(ROOTDIR)/core/include \
            -I$(ROOTDIR)/core/include/glcanvas \
            -I$(ROOTDIR)/core/include/record \
            -I$(ROOTDIR)/thirdparty/MonkVG/include/MonkVG \
            -I$(ROOTDIR)/thirdparty/TouchVGShape/core/include/canvas \
            -I$(ROOTDIR)/thirdparty/TouchVGShape/core/include/test

include $(ROOTDIR)/core/mk/config.mk
include $(ROOTDIR)/core/mk/Makefile.swig

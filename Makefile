TARGET = iphone:clang:latest:14.0
ARCHS = arm64 arm64e

include $(THEOS)/makefiles/common.mk

TWEAK_NAME = zdysj
zdysj_FILES = Tweak.xm ZDYSJManager.m
zdysj_CFLAGS = -fobjc-arc
zdysj_FRAMEWORKS = Foundation UIKit

include $(THEOS_MAKE_PATH)/tweak.mk

TARGET = iphone:clang:latest:14.0
ARCHS = arm64 arm64e

SCHEME ?= rootless
ifeq ($(SCHEME),rootful)
    unexport THEOS_PACKAGE_SCHEME
else ifeq ($(SCHEME),rootless)
    export THEOS_PACKAGE_SCHEME = rootless
    export FINALPACKAGE = 1
else
    $(error Unknown SCHEME=$(SCHEME); use rootless or rootful)
endif

export DEBUG = 0
INSTALL_TARGET_PROCESSES = Aweme

include $(THEOS)/makefiles/common.mk

TWEAK_NAME = zdysj
zdysj_FILES = Tweak.xm ZDYSJManager.m ZDYSJSettingViewController.m
zdysj_CFLAGS = -fobjc-arc
zdysj_FRAMEWORKS = Foundation UIKit

include $(THEOS_MAKE_PATH)/tweak.mk

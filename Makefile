ARCHS = arm64 arm64e
TARGET = iphone:clang:17.2:14.0
INSTALL_TARGET_PROCESSES = WeChat

include $(THEOS)/makefiles/common.mk

TWEAK_NAME = WeChatMomentsScheduler

WeChatMomentsScheduler_FILES = Tweak.x Scheduler.m Task.m TaskListViewController.m
WeChatMomentsScheduler_CFLAGS = -fobjc-arc -Wno-deprecated-declarations
WeChatMomentsScheduler_FRAMEWORKS = UIKit Foundation Photos AVFoundation
WeChatMomentsScheduler_LIBRARIES = sqlite3

include $(THEOS_MAKE_PATH)/tweak.mk

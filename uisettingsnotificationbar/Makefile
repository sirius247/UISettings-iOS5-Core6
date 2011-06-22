include theos/makefiles/common.mk

BUNDLE_NAME = UISettingsNotificationBar
UISettingsNotificationBar_FILES = UISettingsNotificationBarController.m TouchFix.m
UISettingsNotificationBar_INSTALL_PATH = /System/Library/WeeAppPlugins/
UISettingsNotificationBar_FRAMEWORKS = UIKit

include $(THEOS_MAKE_PATH)/bundle.mk

after-install::
	install.exec "killall -9 SpringBoard"

include theos/makefiles/common.mk

SUBPROJECTS = uisettingsnotificationbar uicore uitoggles
include $(THEOS_MAKE_PATH)/aggregate.mk
after-install::
	install.exec "killall -9 SpringBoard"


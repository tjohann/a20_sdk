#
# my simple makefile act as something like a user interface
#

ifeq "${ARMHF_HOME}" ""
    $(error error: please source armhf_env first!)
endif

ifeq "${ARMHF_BIN_HOME}" ""
    $(error error: please source armhf_env first!)
endif

ifeq "${ARMHF_SRC_HOME}" ""
    $(error error: please source armhf_env first!)
endif

MODULES = $(shell ls -d */ | cut -f1 -d'/')
DOCS =

all::
	@echo Cheers

install::
	(install $(ARMHF_HOME)/scripts/make_sdcard.sh $(HOME)/bin/a20_sdk_make_sdcard.sh)

uninstall::
	(rm -rf $(HOME)/bin/a20_sdk_make_sdcard.sh)

clean::
	rm -f *~
	for dir in $(MODULES); do (cd $$dir && $(MAKE) $@); done

distclean: clean

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

all::
	@echo Cheers

clean::
	rm -f *~
	for dir in $(MODULES); do (cd $$dir && $(MAKE) $@); done

distclean::
	rm -f *~
	rm -rf $(ARMHF_SRC_HOME)/{include,lib,lib_target,examples,bin}

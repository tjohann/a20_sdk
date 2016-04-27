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

MODULES = $(shell ls -d */ | cut -f1 -d'/' | grep -v documents | grep -v void-packages)
MODULES_GIT = $(shell ls -d */ | cut -f1 -d'/')

all::
	@echo Cheers

clean::
	rm -f *~ *.o .*~
	for dir in $(MODULES); do (cd $$dir/ && $(MAKE) $@); done

distclean::
	rm -f *~ *.o .*~
	($(ARMHF_HOME)/scripts/clean_sdk.sh -e)

update_all::
	rm -f *~ *.o
	for dir in $(MODULES_GIT); do (cd $$dir && git pull); done

get_external_repos::
	($(ARMHF_HOME)/scripts/get_external_git_repos.sh -p "git")

get_rt-tests::
	($(ARMHF_HOME)/scripts/get_external_git_repos.sh -r "rt-tests" -p "http")

get_uboot::
	($(ARMHF_HOME)/scripts/get_external_git_repos.sh -r "uboot" -p "http")

get_can-utils::
	($(ARMHF_HOME)/scripts/get_external_git_repos.sh -r "can-utils" -p "http")

get_jailhouse::
	($(ARMHF_HOME)/scripts/get_external_git_repos.sh -r "jailhouse" -p "git")

get_allwinner::
	($(ARMHF_HOME)/scripts/get_external_git_repos.sh -r "allwinner" -p "git")

get_sdk_builder::
	($(ARMHF_HOME)/scripts/get_external_git_repos.sh -r "sdk_builder" -p "https")

get_lcd1602::
	($(ARMHF_HOME)/scripts/get_external_git_repos.sh -r "lcd1602" -p "https")

get_mydriver::
	($(ARMHF_HOME)/scripts/get_external_git_repos.sh -r "mydriver" -p "https")

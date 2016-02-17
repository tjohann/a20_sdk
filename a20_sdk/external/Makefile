#
# ${ARMHF_HOME}/external/Makefile
#

ifeq "${ARMHF_HOME}" ""
    $(error error: please source armhf_env first!)
endif

ifeq "${ARMHF_BIN_HOME}" ""
    $(error error: please source armhf_env first!)
endif


MODULES = $(shell ls -d */ | cut -f1 -d'/' | grep -v documents | grep -v void-packages)
MODULES_GIT = $(shell ls -d */ | cut -f1 -d'/')

.PHONY: all
all: 
	@echo Cheers

.PHONY: clean
clean:
	rm -f *~ *.o .*~
	for dir in $(MODULES); do (cd $$dir/ && $(MAKE) $@); done

distclean: clean

#
# update all cloned repos
#
.PHONY: update_all
update_all:
	rm -f *~ *.o
	for dir in $(MODULES_GIT); do (cd $$dir && git pull); done

#
# clone a single external repo (on the device)
#
get_linux-linus::
	($(ARMHF_HOME)/scripts/get_external_git_repos.sh -r "linus" -p "http")

get_rt-tests::
	($(ARMHF_HOME)/scripts/get_external_git_repos.sh -r "rt-tests" -p "http")

get_ipipe::
	($(ARMEL_HOME)/scripts/get_external_git_repos.sh -r "ipipe" -p "http")

get_xenomai::
	($(ARMEL_HOME)/scripts/get_external_git_repos.sh -r "xenomai" -p "http")

get_uboot::
	($(ARMHF_HOME)/scripts/get_external_git_repos.sh -r "uboot" -p "http")

get_mydriver::
	($(ARMHF_HOME)/scripts/get_external_git_repos.sh -r "mydriver" -p "http")

get_can-utils::
	($(ARMHF_HOME)/scripts/get_external_git_repos.sh -r "can-utils" -p "http")

get_libsocketcan::
	($(ARMHF_HOME)/scripts/get_external_git_repos.sh -r "libsocketcan" -p "git")

get_void-packages::
	($(ARMHF_HOME)/scripts/get_external_git_repos.sh -r "void-packages" -p "git")

get_jailhouse::
	($(ARMHF_HOME)/scripts/get_external_git_repos.sh -r "jailhouse" -p "git")

get_allwinner::
	($(ARMHF_HOME)/scripts/get_external_git_repos.sh -r "allwinner" -p "git")

get_sllin::
	($(ARMHF_HOME)/scripts/get_external_git_repos.sh -r "my_sllin" -p "http")

get_sdk_builder::
	($(ARMHF_HOME)/scripts/get_external_git_repos.sh -r "sdk_builder" -p "http")

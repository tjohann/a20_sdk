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

MODULES = $(shell ls -d */ | cut -f1 -d'/' | grep -v documents)
MODULES_GIT = $(shell ls -d */ | cut -f1 -d'/')

all::
	@echo "+----------------------------------------------------------+"
	@echo "|                                                          |"
	@echo "|                  Nothing to build                        |"
	@echo "|                                                          |"
	@echo "+----------------------------------------------------------+"
	@echo "| Example:                                                 |"
	@echo "| make get_external_repos -> get ALL git repos like u-boot |"
	@echo "| make get_rt-tests       -> clone rt test suite           |"
	@echo "| make get_uboot          -> clone u-boot                  |"
	@echo "| make get_can-utils      -> clone can-utils               |"
	@echo "| make get_jailhouse      -> clone jailhouse hypervisor    |"
	@echo "| make get_allwinner      -> get allwinner docs            |"
	@echo "| make get_sdk_builder    -> clone my sdk_builder gui      |"
	@echo "| make get_lcd1602        -> clone my lcd kernel driver    |"
	@echo "| make get_mydriver       -> clone my learning kernel      |"
	@echo "|                            driver                        |"
	@echo "| make get_libbaalue      -> clone my common librar        |"
	@echo "| make get_baalued        -> clone my admin daemon         |"
	@echo "| make get_tt-env         -> clone time-triggert           |"
	@echo "|                            environment playground        |"
	@echo "| make get_can-lin-env    -> clone can/lin bus             |"
	@echo "|                            environment playground        |"
	@echo "| make get_void-packages  -> clone void-packages           |"
	@echo "| make clean              -> clean all dir/subdirs         |"
	@echo "| make distclean          -> complete cleanup/delete       |"
	@echo "+----------------------------------------------------------+"

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

get_base_repos::
	($(ARMHF_HOME)/scripts/get_external_git_repos.sh -r "can-utils" -p "http")
	($(ARMHF_HOME)/scripts/get_external_git_repos.sh -r "mydriver" -p "https")
	($(ARMHF_HOME)/scripts/get_external_git_repos.sh -r "libbaalue" -p "https")
	($(ARMHF_HOME)/scripts/get_external_git_repos.sh -r "baalued" -p "https")
	($(ARMHF_HOME)/scripts/get_external_git_repos.sh -r "tt-env" -p "https")
	($(ARMHF_HOME)/scripts/get_external_git_repos.sh -r "lcd1602" -p "https")
	($(ARMHF_HOME)/scripts/get_external_git_repos.sh -r "can-lin-env" -p "https")

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

get_libbaalue::
	($(ARMHF_HOME)/scripts/get_external_git_repos.sh -r "libbaalue" -p "https")

get_baalued::
	($(ARMHF_HOME)/scripts/get_external_git_repos.sh -r "baalued" -p "https")

get_tt-env::
	($(ARMHF_HOME)/scripts/get_external_git_repos.sh -r "tt-env" -p "https")

get_can-lin-env::
	($(ARMHF_HOME)/scripts/get_external_git_repos.sh -r "can-lin-env" -p "https")

get_void-packages::
	($(ARMHF_HOME)/scripts/get_external_git_repos.sh -r "void-packages" -p "https")

build_base_repos::
	($(ARMHF_HOME)/scripts/helper/build_base_repos.sh)

uninstall_base_repos::
	($(ARMHF_HOME)/scripts/helper/build_base_repos.sh -u)


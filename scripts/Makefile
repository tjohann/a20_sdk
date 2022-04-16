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
	(install $(ARMHF_HOME)/scripts/mount_partitions.sh $(HOME)/bin/a20_sdk_mount_partitions.sh)
	(install $(ARMHF_HOME)/scripts/helper/copy_kernel_dts_to_a20_rep $(HOME)/bin/a20_copy_kernel_dts_to_a20_repo.sh)

uninstall::
	(rm -rf $(HOME)/bin/a20_sdk_make_sdcard.sh)
	(rm -rf $(HOME)/bin/a20_sdk_mount_partitions.sh)
	(rm -rf $(HOME)/bin/a20_copy_kernel_dts_to_a20_repo.sh)

clean::
	rm -f *~
	for dir in $(MODULES); do (cd $$dir && $(MAKE) $@); done

distclean: clean

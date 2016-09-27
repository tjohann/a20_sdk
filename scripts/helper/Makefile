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
	@echo "+----------------------------------------------------------+"
	@echo "|                                                          |"
	@echo "|                  Nothing to build                        |"
	@echo "|                                                          |"
	@echo "+----------------------------------------------------------+"
	@echo "| Example:                                                 |"
	@echo "| make prepare_kernel_image_tarballs                       |"
	@echo "| make prepare_image_tarballs                              |"
	@echo "| make prepare_kernel_folder                               |"
	@echo "| make clean                                               |"
	@echo "| make distclean                                           |"
	@echo "+----------------------------------------------------------+"

prepare_kernel_image_tarballs::
	($(ARMHF_HOME)/scripts/helpers/prepare_all_kernel_image_tarballs.sh)

prepare_image_tarballs::
	($(ARMHF_HOME)/scripts/helpers/prepare_image_tarballs.sh)

prepare_kernel_folder::
	($(ARMHF_HOME)/scripts/helpers/prepare_kernel_folder.sh)

clean::
	rm -f *~
	for dir in $(MODULES); do (cd $$dir && $(MAKE) $@); done

distclean: clean

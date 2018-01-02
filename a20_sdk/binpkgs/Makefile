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

all::
	@echo "+----------------------------------------------------------+"
	@echo "|                                                          |"
	@echo "|                  Nothing to build                        |"
	@echo "|                                                          |"
	@echo "+----------------------------------------------------------+"
	@echo "| make get_binpkgs  -> download latest binpgs              |"
	@echo "| make clean        -> simple clean (no subdir)            |"
	@echo "| make distclean    -> rm also downloaded/build parts      |"
	@echo "+----------------------------------------------------------+"

clean::
	rm -f *~
	rm binpkgs.tgz

distclean::
	rm -f *~
	($(ARMHF_HOME)/scripts/clean_sdk.sh -b)

get_binpkgs::
	@echo "+----------------------------------------------------------+"
	@echo "|                                                          |"
	@echo "|        Download latest binpkgs                           |"
	@echo "|                                                          |"
	@echo "+----------------------------------------------------------+"
	($(ARMHF_HOME)/scripts/helper/get_binpkgs.sh)

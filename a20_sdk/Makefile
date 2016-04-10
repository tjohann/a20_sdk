# only for cleaning


MODULES = $(shell ls -d */ | cut -f1 -d'/' | grep -v toolchain | grep -v host)

.PHONY: all
all: 
	@echo Cheers

.PHONY: clean
clean:
	rm -f *~
	for dir in $(MODULES); do (cd $$dir && $(MAKE) $@); done

distclean: clean clean_toolchain clean_external clean_kernel clean_images

clean_toolchain::
	rm -rf $(ARMHF_BIN_HOME)/toolchain
	rm -f $(ARMHF_BIN_HOME)/toolchain_x86_64.tgz
	rm -rf $(ARMHF_BIN_HOME)/host
	rm -f $(ARMHF_BIN_HOME)/host_x86_64.tgz

clean_external::
	rm -rf $(ARMHF_BIN_HOME)/external

clean_kernel::
	rm -rf $(ARMHF_BIN_HOME)/kernel

clean_images::
	rm -rf $(ARMHF_BIN_HOME)/images

init_sdk: distclean 
	@echo "+----------------------------------------------------------+"
	@echo "|                                                          |"
	@echo "|              Init SDK -> you may need sudo               |"
	@echo "|                                                          |"
	@echo "+----------------------------------------------------------+"
	rm -rf $(ARMHF_SRC_HOME)/{include,lib,lib_target,examples,bin}
	($(ARMHF_HOME)/scripts/init_sdk.sh)

#
# run all get actions in sequence
#
get_all:: get_toolchain get_image_tarballs get_external_repos get_latest_kernel 
	@echo "+----------------------------------------------------------+"
	@echo "|                                                          |"
	@echo "|               All 'get' actions complete                 |"
	@echo "|                                                          |"
	@echo "+----------------------------------------------------------+"

get_external_repos: clean_external
	@echo "+----------------------------------------------------------+"
	@echo "|                                                          |"
	@echo "|               Clone useful external repos                |"
	@echo "|                                                          |"
	@echo "+----------------------------------------------------------+"
	($(ARMHF_HOME)/scripts/get_external_git_repos.sh -p "git")

get_latest_kernel: clean_kernel
	@echo "+----------------------------------------------------------+"
	@echo "|                                                          |"
	@echo "|        Download latest supported kernel version          |"
	@echo "|                                                          |"
	@echo "+----------------------------------------------------------+"
	($(ARMHF_HOME)/scripts/get_latest_linux_kernel.sh)

get_toolchain: clean_toolchain 
	@echo "+----------------------------------------------------------+"
	@echo "|                                                          |"
	@echo "|        Download latest supported toolchain version       |"
	@echo "|                                                          |"
	@echo "+----------------------------------------------------------+"
	($(ARMHF_HOME)/scripts/get_toolchain.sh)

get_image_tarballs: clean_images 
	@echo "+----------------------------------------------------------+"
	@echo "|                                                          |"
	@echo "|        Download latest supported image tarballs          |"
	@echo "|                                                          |"
	@echo "+----------------------------------------------------------+"
	($(ARMHF_HOME)/scripts/get_image_tarballs.sh -b -c -o -p)


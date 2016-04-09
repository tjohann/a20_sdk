#
# my simple makefile act as something like a user interface
#

ifeq "${ARMHF_HOME}" ""
    $(error error: please source armhf_env first!)
endif

ifeq "${ARMHF_BIN_HOME}" ""
    $(error error: please source armhf_env first!)
endif

MODULES = bananapi bananapi-pro olimex cubietruck
MODULES += include pics configs scripts
MODULES += a20_sdk a20_sdk_src

DOCS = Documentation

all:: 
	@echo "+----------------------------------------------------------+"
	@echo "|                                                          |"
	@echo "|                  Nothing to build                        |"
	@echo "|                                                          |"
	@echo "+----------------------------------------------------------+"
	@echo "| Example:                                                 |"
	@echo "| make init_sdk           -> init all needed part          |"
	@echo "| make get_external_repos -> get external repos like linux,|"
	@echo "|                            xenomai or uboot ...          |"
	@echo "| make get_toolchain      -> install toolchain             |"
	@echo "| make get_latest_kernel  -> download latest kernel version|"
	@echo "| make get_image_tarballs -> download image tarballs       |"
	@echo "| make get_all            -> get all of the above          |"
	@echo "| make clean              -> clean all dir/subdirs         |"
	@echo "| make distclean          -> complete cleanup              |"
	@echo "+----------------------------------------------------------+"	


clean::
	rm -f *~ .*~
	for dir in $(MODULES); do (cd $$dir && $(MAKE) $@); done


distclean: clean
	rm -rf $(ARMHF_BIN_HOME)/toolchain
	rm -f $(ARMHF_BIN_HOME)/toolchain_x86_64.tgz
	rm -rf $(ARMHF_BIN_HOME)/host
	rm -f $(ARMHF_BIN_HOME)/host_x86_64.tgz


init_sdk: distclean
	@echo "+----------------------------------------------------------+"
	@echo "|                                                          |"
	@echo "|              Init SDK -> you may need sudo               |"
	@echo "|                                                          |"
	@echo "+----------------------------------------------------------+"
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


#
# clone some useful repos (see $ARMHF_BIN_HOME/external/README)
#
get_external_repos:: 
	@echo "+----------------------------------------------------------+"
	@echo "|                                                          |"
	@echo "|               Clone useful external repos                |"
	@echo "|                                                          |"
	@echo "+----------------------------------------------------------+"
	($(ARMHF_HOME)/scripts/get_external_git_repos.sh -p "git")


#
# download latest supported kernel version as tarball and install it to
# ./kernel/linux-$ARMHF_KERNEL_VER
#
get_latest_kernel:: 
	@echo "+----------------------------------------------------------+"
	@echo "|                                                          |"
	@echo "|        Download latest supported kernel version          |"
	@echo "|                                                          |"
	@echo "+----------------------------------------------------------+"
	($(ARMHF_HOME)/scripts/get_latest_linux_kernel.sh)


#
# download toolchain version as tarball and install it to $ARMHF_HOME
#
get_toolchain: distclean 
	@echo "+----------------------------------------------------------+"
	@echo "|                                                          |"
	@echo "|        Download latest supported toolchain version       |"
	@echo "|                                                          |"
	@echo "+----------------------------------------------------------+"
	($(ARMHF_HOME)/scripts/get_toolchain.sh)


#
# download image tarballs to $ARMHF_BIN_HOME/images
#
get_image_tarballs:  
	@echo "+----------------------------------------------------------+"
	@echo "|                                                          |"
	@echo "|        Download latest supported image tarballs          |"
	@echo "|                                                          |"
	@echo "+----------------------------------------------------------+"
	($(ARMHF_HOME)/scripts/get_image_tarballs.sh -b -c -o -p)


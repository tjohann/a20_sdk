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

MODULES = bananapi bananapi-pro olimex cubietruck
MODULES += include pics configs scripts
MODULES += a20_sdk a20_sdk_src

all:: 
	@echo "+----------------------------------------------------------+"
	@echo "|                                                          |"
	@echo "|                  Nothing to build                        |"
	@echo "|                                                          |"
	@echo "+----------------------------------------------------------+"
	@echo "| Example:                                                 |"
	@echo "| make init_sdk           -> init all needed part          |"
	@echo "| make get_external_repos -> get git repos like u-boot     |"
	@echo "| make get_toolchain      -> install toolchain             |"
	@echo "| make get_latest_kernel  -> download latest kernel version|"
	@echo "| make get_image_tarballs -> download image tarballs       |"
	@echo "| make get_..._image_tarballs -> download specific tarball |"
	@echo "| make get_all            -> get all of the above          |"
	@echo "| make clean              -> clean all dir/subdirs         |"
	@echo "| make distclean          -> complete cleanup/delete       |"
	@echo "| ...                                                      |"
	@echo "+----------------------------------------------------------+"	

clean::
	rm -f *~ .*~
	for dir in $(MODULES); do (cd $$dir && $(MAKE) $@); done

distclean: clean clean_toolchain clean_external clean_kernel clean_images

clean_toolchain::
	($(ARMHF_HOME)/scripts/clean_sdk.sh -t)

clean_external::
	($(ARMHF_HOME)/scripts/clean_sdk.sh -e)

clean_kernel::
	($(ARMHF_HOME)/scripts/clean_sdk.sh -k)

clean_images::
	($(ARMHF_HOME)/scripts/clean_sdk.sh -i)

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
	($(ARMHF_HOME)/scripts/get_image_tarballs.sh -a)

get_bananapi_image_tarballs::  
	@echo "+----------------------------------------------------------+"
	@echo "|                                                          |"
	@echo "|        Download latest bananapi image tarballs           |"
	@echo "|                                                          |"
	@echo "+----------------------------------------------------------+"
	($(ARMHF_HOME)/scripts/get_image_tarballs.sh -b)

get_bananapi-pro_image_tarballs::  
	@echo "+----------------------------------------------------------+"
	@echo "|                                                          |"
	@echo "|        Download latest bananapi-pro image tarballs       |"
	@echo "|                                                          |"
	@echo "+----------------------------------------------------------+"
	($(ARMHF_HOME)/scripts/get_image_tarballs.sh -p)

get_bananapi-pro-hdd_image_tarballs::  
	@echo "+----------------------------------------------------------+"
	@echo "|                                                          |"
	@echo "|        Download latest bananapi-pro-hdd image tarballs   |"
	@echo "|                                                          |"
	@echo "+----------------------------------------------------------+"
	($(ARMHF_HOME)/scripts/get_image_tarballs.sh -e)

get_cubietruck_image_tarballs::  
	@echo "+----------------------------------------------------------+"
	@echo "|                                                          |"
	@echo "|        Download latest cubietruck image tarballs         |"
	@echo "|                                                          |"
	@echo "+----------------------------------------------------------+"
	($(ARMHF_HOME)/scripts/get_image_tarballs.sh -c)

get_cubietruck-hdd_image_tarballs::  
	@echo "+----------------------------------------------------------+"
	@echo "|                                                          |"
	@echo "|        Download latest cubietruck-hdd image tarballs     |"
	@echo "|                                                          |"
	@echo "+----------------------------------------------------------+"
	($(ARMHF_HOME)/scripts/get_image_tarballs.sh -d)

get_olimex_image_tarballs::  
	@echo "+----------------------------------------------------------+"
	@echo "|                                                          |"
	@echo "|        Download latest olimex image tarballs             |"
	@echo "|                                                          |"
	@echo "+----------------------------------------------------------+"
	($(ARMHF_HOME)/scripts/get_image_tarballs.sh -o)

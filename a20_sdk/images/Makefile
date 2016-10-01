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
	@echo "| make get_image_tarballs -> download image tarballs       |"
	@echo "| make get_bananapi_image_tarballs -> download bananapi    |"
	@echo "|                                     image tarballs       |"
	@echo "| make get_bananapi-pro_image_tarballs -> download bananapi|"
	@echo "|                                         image tarballs   |"
	@echo "| make get_cubietruck_image_tarballs -> download cubietruck|"
	@echo "|                                       image tarballs     |"
	@echo "| make get_olimex_image_tarballs -> download olimex image  |"
	@echo "|                                   tarballs               |"
	@echo "| ....                                                     |"
	@echo "| make make_sdcard -> small tool to make a read to use     |"
	@echo "|                     sd-card                              |"
	@echo "| ....                                                     |"
	@echo "| make prepare_kernel_image_tarballs                       |"
	@echo "| make prepare_image_tarballs                              |"
	@echo "| make prepare_base_image_tarballs                         |"
	@echo "| ....                                                     |"
	@echo "| make clean -> clean all dir/subdirs                      |"
	@echo "| make distclean -> rm also downloaded/build parts         |"
	@echo "+----------------------------------------------------------+"

clean::
	rm -f *~ *.o .*~

distclean::
	rm -f *~ *.o .*~
	($(ARMHF_HOME)/scripts/clean_sdk.sh -i)

#
# download image tarballs
#
get_image_tarballs::
	@echo "+----------------------------------------------------------+"
	@echo "|                                                          |"
	@echo "|        Download latest supported image tarballs          |"
	@echo "|                                                          |"
	@echo "+----------------------------------------------------------+"
	($(ARMHF_HOME)/scripts/get_image_tarballs.sh -b bananapi)
	($(ARMHF_HOME)/scripts/get_image_tarballs.sh -b baalue)
	($(ARMHF_HOME)/scripts/get_image_tarballs.sh -b bananapi-pro)
	($(ARMHF_HOME)/scripts/get_image_tarballs.sh -b cubietruck)
	($(ARMHF_HOME)/scripts/get_image_tarballs.sh -b olimex)

get_bananapi_image_tarballs::
	@echo "+----------------------------------------------------------+"
	@echo "|                                                          |"
	@echo "|        Download latest bananapi image tarballs           |"
	@echo "|                                                          |"
	@echo "+----------------------------------------------------------+"
	($(ARMHF_HOME)/scripts/get_image_tarballs.sh -b bananapi)

get_baalue_image_tarballs::
	@echo "+----------------------------------------------------------+"
	@echo "|                                                          |"
	@echo "|        Download latest bananapi image tarballs           |"
	@echo "|                                                          |"
	@echo "+----------------------------------------------------------+"
	($(ARMHF_HOME)/scripts/get_image_tarballs.sh -b baalue)

get_bananapi-pro_image_tarballs::
	@echo "+----------------------------------------------------------+"
	@echo "|                                                          |"
	@echo "|        Download latest bananapi-pro image tarballs       |"
	@echo "|                                                          |"
	@echo "+----------------------------------------------------------+"
	($(ARMHF_HOME)/scripts/get_image_tarballs.sh -b bananapi-pro)

get_cubietruck_image_tarballs::
	@echo "+----------------------------------------------------------+"
	@echo "|                                                          |"
	@echo "|        Download latest cubietruck image tarballs         |"
	@echo "|                                                          |"
	@echo "+----------------------------------------------------------+"
	($(ARMHF_HOME)/scripts/get_image_tarballs.sh -b cubietruck)

get_olimex_image_tarballs::
	@echo "+----------------------------------------------------------+"
	@echo "|                                                          |"
	@echo "|        Download latest olimex image tarballs             |"
	@echo "|                                                          |"
	@echo "+----------------------------------------------------------+"
	($(ARMHF_HOME)/scripts/get_image_tarballs.sh -b olimex)

prepare_kernel_image_tarballs::
	($(ARMHF_HOME)/scripts/helper/prepare_all_kernel_image_tarballs.sh)

prepare_image_tarballs::
	($(ARMHF_HOME)/scripts/helper/prepare_image_tarballs.sh)

prepare_base_image_tarballs::
	($(ARMHF_HOME)/scripts/helper/prepare_image_tarballs.sh -e)

#
# create ready to use sdcards
#
make_sdcard::
	@echo "+----------------------------------------------------------+"
	@echo "|                                                          |"
	@echo "|              Start tool to make a SD-Card                |"
	@echo "|                                                          |"
	@echo "+----------------------------------------------------------+"
	($(ARMHF_HOME)/scripts/make_sdcard.sh)

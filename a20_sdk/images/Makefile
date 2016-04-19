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
	@echo "| make get_bananapi_image_tarballs   -> download bananapi  |"
	@echo "| image tarballs                                           |"
	@echo "| make get_bananapi-pro_image_tarballs -> download bananapi|"
	@echo "| image tarballs                                           |"
	@echo "| make get_cubietruck_image_tarballs -> download cubietruck|"
	@echo "| image tarballs                                           |"
	@echo "| make get_olimex_image_tarballs     -> download olimex    |"
	@echo "| image tarballs                                           |"
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
	@echo "|       Download all latest supported image tarballs       |"
	@echo "|                                                          |"
	@echo "+----------------------------------------------------------+"
	($(ARMHF_HOME)/scripts/get_image_tarballs.sh -a)

get_bananapi_image_tarballs::
	@echo "+----------------------------------------------------------+"
	@echo "|                                                          |"
	@echo "|     Download latest supported bananapi image tarballs    |"
	@echo "|                                                          |"
	@echo "+----------------------------------------------------------+"
	($(ARMHF_HOME)/scripts/get_image_tarballs.sh -b)


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

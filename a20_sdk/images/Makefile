# only for cleaning

#MODULES = $(shell ls -d */ | cut -f1 -d'/')

ifeq "${ARMHF_HOME}" ""
    $(error error: please source armhf_env first!)
endif

ifeq "${ARMHF_BIN_HOME}" ""
    $(error error: please source armhf_env first!)
endif


.PHONY: all
all: 
	@echo "+----------------------------------------------------------+"
	@echo "|                                                          |"
	@echo "|                  Nothing to build                        |"
	@echo "|                                                          |"
	@echo "+----------------------------------------------------------+"
	@echo "| make get_image_tarballs -> download image tarballs       |"
	@echo "| make get_bananapi_image_tarballs   -> download bananapi  |"
	@echo "| image tarballs                                           |"
	@echo "| make get_bananapi_pro_image_tarballs -> download bananapi|"
	@echo "| image tarballs                                           |"
	@echo "| make get_cubietruck_image_tarballs -> download cubietruck|"
	@echo "| image tarballs                                           |"
	@echo "| make get_olimex_image_tarballs     -> download olimex    |"
	@echo "| image tarballs                                           |"
	@echo "| make clean -> clean all dir/subdirs                      |"
	@echo "| make distclean -> rm also downloaded/build parts         |"	
	@echo "+----------------------------------------------------------+"	

.PHONY: clean
clean:
	rm -f *~ *.o .*~
#	for dir in $(MODULES); do (cd $$dir && $(MAKE) $@); done

distclean: clean
	rm -rf *.tgz

#
# download image tarballs to $ARMHF_HOME/images
#
get_image_tarballs:  
	@echo "+----------------------------------------------------------+"
	@echo "|                                                          |"
	@echo "|       Download all latest supported image tarballs       |"
	@echo "|                                                          |"
	@echo "+----------------------------------------------------------+"
	($(ARMHF_HOME)/scripts/get_image_tarballs.sh -a)


get_bananapi_image_tarballs:  
	@echo "+----------------------------------------------------------+"
	@echo "|                                                          |"
	@echo "|     Download latest supported bananapi image tarballs    |"
	@echo "|                                                          |"
	@echo "+----------------------------------------------------------+"
	($(ARMHF_HOME)/scripts/get_image_tarballs.sh -b)


get_bananapi_pro_image_tarballs:  
	@echo "+----------------------------------------------------------+"
	@echo "|                                                          |"
	@echo "|     Download latest supported bananapi-pro image tarballs|"
	@echo "|                                                          |"
	@echo "+----------------------------------------------------------+"
	($(ARMHF_HOME)/scripts/get_image_tarballs.sh -p)


get_olimex_image_tarballs:  
	@echo "+----------------------------------------------------------+"
	@echo "|                                                          |"
	@echo "|     Download latest supported olimex image tarballs      |"
	@echo "|                                                          |"
	@echo "+----------------------------------------------------------+"
	($(ARMHF_HOME)/scripts/get_image_tarballs.sh -o)


get_cubietruck_image_tarballs:  
	@echo "+----------------------------------------------------------+"
	@echo "|                                                          |"
	@echo "|     Download latest supported cubietruck image tarballs  |"
	@echo "|                                                          |"
	@echo "+----------------------------------------------------------+"
	($(ARMHF_HOME)/scripts/get_image_tarballs.sh -c)

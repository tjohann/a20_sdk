# only for cleaning 

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
	@echo "| make get_latest_kernel  -> download latest kernel version|"
	@echo "| make clean              -> clean all dir/subdirs         |"
	@echo "| make distclean          -> rm also downloaded/build parts|"	
	@echo "+----------------------------------------------------------+"	

.PHONY: clean
clean:
	rm -f *~

distclean: clean
	rm -rf patch-*
	rm -rf modules_*
	rm -rf linux-*

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

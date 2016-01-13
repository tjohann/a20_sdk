# only for cleaning 

.PHONY: all
all: 
	@echo "+----------------------------------------------------------+"
	@echo "|                                                          |"
	@echo "|                  Nothing to build                        |"
	@echo "|                                                          |"
	@echo "+----------------------------------------------------------+"
	@echo "| make get_latest_kernel  -> download latest kernel version|"
	@echo "| make clean              -> clean all dir/subdirs         |"
	@echo "+----------------------------------------------------------+"	

.PHONY: clean
clean:
	rm -f *~

distclean: clean

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

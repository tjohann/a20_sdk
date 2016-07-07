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
	@echo "| make get_latest_kernel  -> download latest kernel version|"
	@echo "| make get_latest_rt_kernel -> download latest rt kernel   |"
	@echo "| make get_latest_nonrt_kernel -> download latest nonrt ...|"
	@echo "| make clean              -> clean all dir/subdirs         |"
	@echo "| make distclean          -> rm also downloaded/build parts|"
	@echo "+----------------------------------------------------------+"

clean::
	rm -f *~

distclean::
	rm -f *~
	($(ARMHF_HOME)/scripts/clean_sdk.sh -k)

get_latest_kernel::
	@echo "+----------------------------------------------------------+"
	@echo "|                                                          |"
	@echo "|        Download latest supported kernel version          |"
	@echo "|                                                          |"
	@echo "+----------------------------------------------------------+"
	($(ARMHF_HOME)/scripts/get_latest_linux_kernel.sh -a)

get_latest_rt_kernel::
	@echo "+----------------------------------------------------------+"
	@echo "|                                                          |"
	@echo "|        Download latest supported rt kernel version       |"
	@echo "|                                                          |"
	@echo "+----------------------------------------------------------+"
	($(ARMHF_HOME)/scripts/get_latest_linux_kernel.sh -r)

get_latest_nonrt_kernel::
	@echo "+----------------------------------------------------------+"
	@echo "|                                                          |"
	@echo "|        Download latest supported nonrt kernel version    |"
	@echo "|                                                          |"
	@echo "+----------------------------------------------------------+"
	($(ARMHF_HOME)/scripts/get_latest_linux_kernel.sh -n)

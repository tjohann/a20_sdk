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
	@echo "| make build_latest_kernel -> build rt and non-rt kernel   |"
	@echo "| make build_rt_kernel -> build rt kernel                  |"
	@echo "| make build_non-rt_kernel -> build non-rt kernel          |"
	@echo "| make clean              -> simple clean (no subdir)      |"
	@echo "| make distclean          -> rm also downloaded/build parts|"
	@echo "| ----------- installs below are for bananapi ------------ |"
	@echo "| make install_latest_kernel -> install rt and non-rt      |"
	@echo "|                               kernel                     |"
	@echo "| make install_rt_kernel -> install rt kernel              |"
	@echo "| make install_non-rt_kernel -> install non-rt kernel      |"
	@echo "| ------------------ helper scripts ---------------------- |"
	@echo "| make prepare_kernel_folder                               |"
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
	@echo "|        Download latest supported non-rt kernel version   |"
	@echo "|                                                          |"
	@echo "+----------------------------------------------------------+"
	($(ARMHF_HOME)/scripts/get_latest_linux_kernel.sh -n)

build_rt_kernel::
	@echo "+----------------------------------------------------------+"
	@echo "|                                                          |"
	@echo "|                    build rt kernel                       |"
	@echo "|                                                          |"
	@echo "+----------------------------------------------------------+"
	($(ARMHF_HOME)/scripts/build_kernel.sh -r)

build_non-rt_kernel::
	@echo "+----------------------------------------------------------+"
	@echo "|                                                          |"
	@echo "|                   build non-rt kernel                    |"
	@echo "|                                                          |"
	@echo "+----------------------------------------------------------+"
	($(ARMHF_HOME)/scripts/build_kernel.sh -n)

build_latest_kernel::
	@echo "+----------------------------------------------------------+"
	@echo "|                                                          |"
	@echo "|                    build latest kernel                   |"
	@echo "|                                                          |"
	@echo "+----------------------------------------------------------+"
	($(ARMHF_HOME)/scripts/build_kernel.sh -a)

install_rt_kernel::
	@echo "+----------------------------------------------------------+"
	@echo "|                                                          |"
	@echo "|               install rt kernel (bananapi)               |"
	@echo "|                                                          |"
	@echo "+----------------------------------------------------------+"
	($(ARMHF_HOME)/scripts/install_kernel.sh -b bananapi -r)

install_non-rt_kernel::
	@echo "+----------------------------------------------------------+"
	@echo "|                                                          |"
	@echo "|               install non-rt kernel (bananapi)           |"
	@echo "|                                                          |"
	@echo "+----------------------------------------------------------+"
	($(ARMHF_HOME)/scripts/install_kernel.sh -b bananapi -n)

install_latest_kernel::
	@echo "+----------------------------------------------------------+"
	@echo "|                                                          |"
	@echo "|               install latest kernel (bananapi)           |"
	@echo "|                                                          |"
	@echo "+----------------------------------------------------------+"
	($(ARMHF_HOME)/scripts/install_kernel.sh -b bananapi -a)

prepare_kernel_folder::
	($(ARMHF_HOME)/scripts/helpers/prepare_kernel_folder.sh)

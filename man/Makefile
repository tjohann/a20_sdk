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
	@echo Cheers

clean::
	rm -f *~
	rm *.ps

man::
	groff -man ./a20_sdk.7 > ./a20_sdk.ps
	groff -man -Tascii ./a20_sdk.7 | less

distclean: clean

# only for cleaning :-)

ifeq "${ARMHF_HOME}" ""
    $(error error: please source armhf_env first!)
endif

ifeq "${ARMHF_BIN_HOME}" ""
    $(error error: please source armhf_env first!)
endif

ifeq "${ARMHF_SRC_HOME}" ""
    $(error error: please source armhf_env first!)
endif

.PHONY: all
all:
	@echo Cheers

.PHONY: clean
clean:
	rm -f *~ .*~
	rm -f hdd_boot/*~
	rm -f tty_console/*~

distclean: clean

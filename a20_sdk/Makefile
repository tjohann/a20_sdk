# only for cleaning


MODULES = $(shell ls -d */ | cut -f1 -d'/' | grep -v toolchain | grep -v host)

.PHONY: all
all: 
	@echo Cheers

.PHONY: clean
clean:
	rm -f *~
	for dir in $(MODULES); do (cd $$dir && $(MAKE) $@); done

distclean:
	rm -f *~
	for dir in $(MODULES); do (cd $$dir && $(MAKE) $@); done
	rm -rf $(ARMHF_BIN_HOME)/toolchain
	rm -f $(ARMHF_BIN_HOME)/toolchain_x86_64.tgz
	rm -rf $(ARMHF_BIN_HOME)/host
	rm -f $(ARMHF_BIN_HOME)/host_x86_64.tgz

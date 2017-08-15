# only for cleaning

ifeq "${ARMHF_HOME}" ""
    $(error error: please source armhf_env first!)
endif

ifeq "${ARMHF_BIN_HOME}" ""
    $(error error: please source armhf_env first!)
endif

ifeq "${ARMHF_SRC_HOME}" ""
    $(error error: please source armhf_env first!)
endif

MODULES = $(shell ls -d */ | cut -f1 -d'/')

.PHONY: all
all:
	@echo Cheers

.PHONY: clean
clean:
	rm -f *~
	for dir in $(MODULES); do (cd $$dir && $(MAKE) $@); done

make_tarballs: clean
	tar czvf hdd_branding_1.tgz hdd_branding_1
	tar czvf hdd_branding_2.tgz hdd_branding_2
	tar czvf hdd_branding_3.tgz hdd_branding_3
	tar czvf hdd_branding_4.tgz hdd_branding_4
	tar czvf hdd_branding_5.tgz hdd_branding_5
	tar czvf hdd_branding_6.tgz hdd_branding_6
	tar czvf hdd_branding_7.tgz hdd_branding_7
	tar czvf hdd_branding_8.tgz hdd_branding_8
	tar czvf hdd_branding_9.tgz hdd_branding_9
	tar czvf hdd_branding_10.tgz hdd_branding_10
	tar czvf hdd_branding_11.tgz hdd_branding_11
	tar czvf hdd_branding_12.tgz hdd_branding_12
	tar czvf hdd_branding_13.tgz hdd_branding_13
	tar czvf hdd_branding_14.tgz hdd_branding_14
	tar czvf hdd_branding_15.tgz hdd_branding_15
	tar czvf hdd_branding_16.tgz hdd_branding_16
	tar czvf hdd_branding.tgz hdd_branding
	tar czvf hdd_branding_master.tgz hdd_branding_master

distclean: clean

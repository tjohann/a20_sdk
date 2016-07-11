# only for cleaning

MODULES = $(shell ls -d */ | cut -f1 -d'/')

.PHONY: all
all:
	@echo Cheers

.PHONY: clean
clean:
	rm -f *~
	for dir in $(MODULES); do (cd $$dir && $(MAKE) $@); done

distclean: clean

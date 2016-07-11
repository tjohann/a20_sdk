# only for cleaning

MODULES = $(shell ls -d */ | cut -f1 -d'/' | grep -v etc)

.PHONY: all
all:
	@echo Cheers

.PHONY: clean
clean:
	rm -f *~
	rm -f etc/*~
	for dir in $(MODULES); do (cd $$dir && $(MAKE) $@); done

distclean: clean

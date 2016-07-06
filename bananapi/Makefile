# only for cleaning

MODULES = $(shell ls -d */ | cut -f1 -d'/' | grep -v branding)

.PHONY: all
all:
	@echo Cheers

.PHONY: clean
clean:
	rm -f *~
	rm -f branding/*~
	for dir in $(MODULES); do (cd $$dir && $(MAKE) $@); done

distclean: clean

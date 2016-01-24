# only for cleaning 

MODULES = $(shell ls -d */ | cut -f1 -d'/')
DOCS = 

all:: 
	@echo Cheers

clean::
	rm -f *~
	for dir in $(MODULES); do (cd $$dir && $(MAKE) $@); done

distclean: clean

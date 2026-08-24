include config.mk

all: build

build:
	@echo "Building 'progs.dat' file."
	$(FTEQCC) $(FTEQCC_FLAGS) -o progs.dat

format:
	find src/ -name '*.qc' -exec $(QCSTYLE) $(QCSTYLE_FLAGS) {} +

package: build
	@echo "Packaging mod into '$(DIST)/'."
	mkdir -p $(DIST)/$(MOD_NAME)
	cp -r gfx gfx.wad maps progs progs.dat sound CFG\ Files/* demos/* $(DIST)/$(MOD_NAME)
	cp README.md $(DIST)

archive: package
	@echo "Creating 'sqate-$(VERSION).zip'."
	cd $(DIST) && $(ARCHIVE) sqate-$(VERSION).zip $(MOD_NAME) README.md

clean:
	@echo "Cleaning up project directory."
	command rm progs.lno progs.dat
	command rm -rf $(DIST)

.PHONY: all build format package archive clean

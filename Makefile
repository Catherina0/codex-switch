PREFIX ?= $(HOME)/.local
INSTALL_DIR ?= $(PREFIX)/bin
PROGRAM := codex-switch
VERSION := $(shell ./bin/$(PROGRAM) --version | awk '{print $$2}')
DIST_DIR := dist
PACKAGE := $(PROGRAM)-$(VERSION)

.PHONY: all check test install uninstall dist clean

all: check

check: test

test:
	bash -n bin/$(PROGRAM)
	bash -n install.sh
	bash -n tests/run.sh
	tests/run.sh

install:
	install -d "$(INSTALL_DIR)"
	install -m 0755 "bin/$(PROGRAM)" "$(INSTALL_DIR)/$(PROGRAM)"
	"$(INSTALL_DIR)/$(PROGRAM)" --version

uninstall:
	rm -f "$(INSTALL_DIR)/$(PROGRAM)"

dist: test
	rm -rf "$(DIST_DIR)"
	mkdir -p "$(DIST_DIR)"
	tmp_dir="$$(mktemp -d)"; \
	  mkdir -p "$$tmp_dir/$(PACKAGE)"; \
	  cp -R bin docs tests README.md LICENSE CHANGELOG.md Makefile install.sh "$$tmp_dir/$(PACKAGE)/"; \
	  if [ -d .github ]; then cp -R .github "$$tmp_dir/$(PACKAGE)/"; fi; \
	  tar -C "$$tmp_dir" -czf "$(DIST_DIR)/$(PACKAGE).tar.gz" "$(PACKAGE)"; \
	  if command -v zip >/dev/null 2>&1; then \
	    (cd "$$tmp_dir" && zip -qr "$(CURDIR)/$(DIST_DIR)/$(PACKAGE).zip" "$(PACKAGE)"); \
	  fi; \
	  rm -rf "$$tmp_dir"

clean:
	rm -rf "$(DIST_DIR)"

#
# Makefile
#
# Copyright (C) 2014, Galois, Inc.
# All Rights Reserved.
#
# Released under the BSD3 license.  See the file "LICENSE"
# for details.
#

CC                := gcc
OCAMLC            := ocamlfind ocamlc
OCAMLOPT          := ocamlfind ocamlopt
OCAMLMKLIB        := ocamlfind ocamlmklib
OCAMLDEP          := ocamlfind ocamldep

OPAM_PREFIX       := $(shell opam config var prefix)
PKG_CONFIG_PATH   := $(OPAM_PREFIX)/lib/pkgconfig
MINIOS_CFLAGS     := $(shell PKG_CONFIG_PATH=$(PKG_CONFIG_PATH) pkg-config --cflags libminios-xen)
MIRAGE_CFLAGS     := -isystem $(shell gcc -print-file-name=include) \
                      -I$(OPAM_PREFIX)/include/mirage-xen/include \
                      -I$(OPAM_PREFIX)/include/mirage-xen/ocaml

CFLAGS            := -nostdinc -fno-builtin $(MIRAGE_CFLAGS) $(MINIOS_CFLAGS)

SOURCES           := lib/flask.ml
INTERFACES        := lib/flask.mli

OCAML_OBJECTS     := $(SOURCES:.ml=.cmx)
OCAML_C_OBJECTS   := $(SOURCES:.ml=.o)
OCAML_CMI         := $(INTERFACES:.mli=.cmi)
NATIVE_OBJECTS    := lib/hypercalls.o
OCAML_LIB         := lib/mirage_flask_xen.cmxa
OCAML_C_LIB       := lib/mirage_flask_xen.a
STUB_LIB_NAME     := mirage_flask_xen_stubs
STUB_LIB          := lib/lib$(STUB_LIB_NAME).a

INSTALL_FILES     := lib/META $(INTERFACES) $(OCAML_CMI) $(OCAML_OBJECTS) \
                     $(OCAML_LIB) $(OCAML_C_LIB) $(STUB_LIB)
CLEAN_FILES       := .depend $(OCAML_CMI) $(OCAML_OBJECTS) $(OCAML_C_OBJECTS) \
                     $(NATIVE_OBJECTS) $(OCAML_LIB) $(OCAML_C_LIB) $(STUB_LIB)

# I can't figure out how to make this work with Oasis and
# cannot be bothered to muck around with myocamlbuild.ml
# scripts, so let's do this the old fashioned way...
.PHONY: build
build: $(OCAML_LIB) $(STUB_LIB)

%.cmi: %.mli
	@echo "OCAMLC       $<"
	@$(OCAMLC) -c -g -I lib -o $@ $<

%.cmx %.o: %.ml
	@echo "OCAMLOPT     $<"
	@$(OCAMLOPT) -c -g -I lib -o $@ $<

%.o: %.c
	@echo "CC           $<"
	@$(CC) $(CFLAGS) -c -o $@ $<

$(OCAML_LIB) $(OCAML_C_LIB): $(OCAML_OBJECTS) $(STUB_LIB)
	@echo "OCAMLOPT     $@"
	@$(OCAMLOPT) -a -cclib -l$(STUB_LIB_NAME) $(OCAML_OBJECTS) -o $@

$(STUB_LIB): $(NATIVE_OBJECTS)
	@echo "OCAMLMKLIB   $@"
	@$(OCAMLMKLIB) -custom -o lib/$(STUB_LIB_NAME) $(NATIVE_OBJECTS)

.PHONY: clean
clean:
	rm -f $(CLEAN_FILES)

.PHONY: install
install: build
	ocamlfind install mirage-flask-xen $(INSTALL_FILES)

.PHONY: uninstall
uninstall:
	ocamlfind remove mirage-flask-xen

.PHONY: reinstall
reinstall:
	@$(MAKE) uninstall
	@$(MAKE) install

.depend: $(INTERFACES) $(SOURCES)
	@$(OCAMLDEP) $(INTERFACES) $(SOURCES) > $@

-include .depend

# vim: set ts=2 noet:

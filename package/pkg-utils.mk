################################################################################
#
# This file contains various utility functions used by the package
# infrastructure, or by the packages themselves.
#
################################################################################

#
# Manipulation of .config files based on the Kconfig
# infrastructure. Used by the BusyBox package, the Linux kernel
# package, and more.
#

define KCONFIG_ENABLE_OPT # (option, file)
	$(Q)$(SED) "/\\<$(1)\\>/d" $(2)
	$(Q)echo '$(1)=y' >> $(2)
endef

define KCONFIG_SET_OPT # (option, value, file)
	$(Q)$(SED) "/\\<$(1)\\>/d" $(3)
	$(Q)echo '$(1)=$(2)' >> $(3)
endef

define KCONFIG_DISABLE_OPT # (option, file)
	$(Q)$(SED) "/\\<$(1)\\>/d" $(2)
	$(Q)echo '# $(1) is not set' >> $(2)
endef

# Helper functions to determine the name of a package and its
# directory from its makefile directory, using the $(MAKEFILE_LIST)
# variable provided by make. This is used by the *-package macros to
# automagically find where the package is located.
pkgdir = $(dir $(lastword $(MAKEFILE_LIST)))
pkgname = $(lastword $(subst /, ,$(pkgdir)))

# Define extractors for different archive suffixes
INFLATE.bz2  = $(BZCAT)
INFLATE.gz   = $(ZCAT)
INFLATE.lzma = $(XZCAT)
INFLATE.tbz  = $(BZCAT)
INFLATE.tbz2 = $(BZCAT)
INFLATE.tgz  = $(ZCAT)
INFLATE.xz   = $(XZCAT)
INFLATE.tar  = cat
# suitable-extractor(filename): returns extractor based on suffix
suitable-extractor = $(INFLATE$(suffix $(1)))

# check-deprecated-variable -- throw an error on deprecated variables
# example:
#   $(eval $(call check-deprecated-variable,FOO_MAKE_OPT,FOO_MAKE_OPTS))
define check-deprecated-variable # (deprecated var, new var)
ifneq ($$(origin $(1)),undefined)
$$(error Package error: use $(2) instead of $(1). Please fix your .mk file)
endif
endef

#
# legal-info helper functions
#
LEGAL_INFO_SEPARATOR = "::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::"

define legal-warning # text
	echo "WARNING: $(1)" >>$(LEGAL_WARNINGS)
endef

define legal-warning-pkg # pkg, text
	echo "WARNING: $(1): $(2)" >>$(LEGAL_WARNINGS)
endef

define legal-warning-nosource # pkg, {local|override}
	$(call legal-warning-pkg,$(1),sources not saved ($(2) packages not handled))
endef

define legal-manifest # pkg, version, license, license-files, source, url, {HOST|TARGET}
	echo '"$(1)","$(2)","$(3)","$(4)","$(5)","$(6)"' >>$(LEGAL_MANIFEST_CSV_$(7))
endef

define legal-license-header # pkg, license-file, {HOST|TARGET}
	printf "$(LEGAL_INFO_SEPARATOR)\n\t$(1):\
		$(2)\n$(LEGAL_INFO_SEPARATOR)\n\n\n" >>$(LEGAL_LICENSES_TXT_$(3))
endef

define legal-license-nofiles # pkg, {HOST|TARGET}
	$(call legal-license-header,$(1),unknown license file(s),$(2))
endef

define legal-license-file # pkg, filename, file-fullpath, {HOST|TARGET}
	$(call legal-license-header,$(1),$(2) file,$(4)) && \
	cat $(3) >>$(LEGAL_LICENSES_TXT_$(4)) && \
	echo >>$(LEGAL_LICENSES_TXT_$(4)) && \
	mkdir -p $(LICENSE_FILES_DIR_$(4))/$(1)/$(dir $(2)) && \
	cp $(3) $(LICENSE_FILES_DIR_$(4))/$(1)/$(2)
endef

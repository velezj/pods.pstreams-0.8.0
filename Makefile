# pod Makefile created using pods-tools/create-configure-pod.sh

FETCH_URL="http://downloads.sourceforge.net/project/pstreams/pstreams/Release%200.8.x/pstreams-0.8.0.tar.gz?r=http%3A%2F%2Fsourceforge.net%2Fprojects%2Fpstreams%2Ffiles%2Fpstreams%2FRelease%25200.8.x%2F"
POD_NAME=pstreams-0.8.0

default_target: all
	@echo ""

# Default to a less-verbose build.  If you want all the gory compiler output,
# run "make VERBOSE=1"
$(VERBOSE).SILENT:

# Figure out where to build the software.
#   Use BUILD_PREFIX if it was passed in.
#   If not, search up to four parent directories for a 'build' directory.
#   Otherwise, use ./build.
ifeq "$(BUILD_PREFIX)" ""
BUILD_PREFIX:=$(shell for pfx in ./ .. ../.. ../../.. ../../../..; do d=`pwd`/$$pfx/build;\
               if [ -d $$d ]; then echo $$d; exit 0; fi; done; echo `pwd`/build)
endif
# create the build directory if needed, and normalize its path name
BUILD_PREFIX:=$(shell mkdir -p $(BUILD_PREFIX) && cd $(BUILD_PREFIX) && echo `pwd`)

# Default to a release build.  If you want to enable debugging flags, run
# "make BUILD_TYPE=Debug"
ifeq "$(BUILD_TYPE)" ""
BUILD_TYPE="Release"
endif


all: pkgconfiged.touch
	@echo "\nBUILD_PREFIX: $(BUILD_PREFIX)\n\n"

	@mkdir -p pod-build
	@touch pod-build/Makefile

fetched.touch:
	$(MAKE) fetch

unarchived.touch: fetched.touch
	$(MAKE) unarchive

built.touch: unarchived.touch
	$(MAKE) build-source

installed.touch: built.touch
	$(MAKE) install-source

pkgconfiged.touch: installed.touch
	$(MAKE) pkgconfig-source

fetch:
	@echo "\n Fetching $(POD_NAME) from $(FETCH_URL) \n"
	wget -O $(POD_NAME).tar.gz $(FETCH_URL)
	@touch fetched.touch

unarchive:
	@echo "\n UnArchiving $(POD_NAME) \n"
	@tar xzf $(POD_NAME).tar.gz
	@touch unarchived.touch

build-source:
	@echo "\n Building $(POD_NAME) \n"
	@mkdir -p pod-build
	@touch built.touch

install-source:
	@echo "\n Installing $(POD_NAME) \n"
	@mkdir -p $(BUILD_PREFIX)/include/pstream/
	@cp $(POD_NAME)/pstream.h $(BUILD_PREFIX)/include/pstream/
	@touch installed.touch

pkgconfig-source:
	@echo "\n Creating pkg-config files for $(POD_NAME) \n"
	@mkdir -p $(BUILD_PREFIX)/lib/pkgconfig
	sed s@PREFIX@$(BUILD_PREFIX)@ $(POD_NAME).pc > $(BUILD_PREFIX)/lib/pkgconfig/$(POD_NAME).pc
	@touch pkgconfiged.touch



clean:
	-if [ -e pod-build/install_manifest.txt ]; then rm -f `cat pod-build/install_manifest.txt`; fi
	rm -rf $(POD_NAME)
	-if [ -e pod-build ]; then rm -rf pod-build; fi
	-if [ -e unarchived.touch ]; then rm unarchived.touch; fi
	-if [ -e built.touch ]; then rm built.touch; fi
	-if [ -e installed.touch ]; then rm installed.touch; fi	
	-if [ -e pkgconfiged.touch ]; then rm pkgconfiged.touch; fi
	-if [ -e $(BUILD_PREFIX)/include/pstream ]; then rm -rf $(BUILD_PREFIX)/include/pstream; fi
	-if [ -e $(BUILD_PREFIX)/lib/pkgconfig/$(POD_NAME).pc ]; then rm -f $(BUILD_PREFIX)/lib/pkgconfig/$(POD_NAME).pc; fi


# other (custom) targets are passed through to the cmake-generated Makefile 
%::
	$(MAKE) -C pod-build $@

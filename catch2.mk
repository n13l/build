CATCH_SINGLE_INCLUDE=$(s)/vendor/Catch2/single_include

tests_src_dir=tests/src
tests_src_cflags=-I$(CATCH_SINGLE_INCLUDE) 
#tests_src_cflags+=-DCATCH_CONFIG_ENABLE_BENCHMARKING
tests_sources=$(shell find $(tests_src_dir) -type f -iname '*.cc')
tests_units=$(patsubst %.cc,$(o)/%.o,$(sort $(tests_sources)))

$(o)/$(tests_src_dir)/000-MAIN-TEST: $(tests_units) 
	$(M)CX $(patsubst $(o)/%,%,$@)
	$(Q)$(CXX) -o $@ $(tests_units) $(LDFLAGS) $(test_ldflags)

build_tests: $(o)/$(tests_src_dir)/000-MAIN-TEST

CC  := $(or ${CC},${CC},gcc)
CXX := $(or ${CXX},${CXX},g++)
AR  := $(or ${AR},${AR},ar)
LD  := $(or ${LD},${LD},ld)

$(o)/%.oo: %.c
	$(Q)mkdir -p $(dir $@)
	$(M)CC   $<
	$(Q)$(CC) -MMD -fPIC $(BUILD_CFLAGS) $(CFLAGS) -o $@ -c $<

$(o)/%.o: %.c
	$(Q)mkdir -p $(dir $@)
	$(M)CC   $<
	$(Q)$(CC) -MMD -fPIC $(BUILD_CFLAGS) $(CFLAGS) -o $@ -c $<

$(o)/%.s: %.c
	$(Q)mkdir -p $(dir $@)
	$(Q)echo -S -fverbose-asm $@ $<

$(o)/%.t: %.c
	$(Q)mkdir -p $(dir $@)
	$(Q)sed -n '/#ifdef TEST/,/endif\/*TEST*/p' $< | grep -q ^ && \
	$(CC) $(CFLAGS) -DTEST -DTEST_VECTORS -o $@ $< || exit 0

$(o)/%.o: %.cc
	$(eval $@_cxxflags=$($(subst /,_,$(dir $(subst $(o)/,,$@))cflags)))
	$(Q)mkdir -p $(dir $@)
	$(M)CX    $<
	$(Q)$(CXX) $(CXXFLAGS) -o $@ -c $< $($@_cxxflags)

$(o)/%built-in.o:
	$(Q)mkdir -p $(dir $@)
	$(M)LD   $(patsubst $(o)/%,%,$@) $(BUILD_LDFLAGS)
	$(Q)ld -r $^ -o $@

$(o)/%: $(o)/%.o
	$(Q)mkdir -p $(dir $@)
	$(M)LD   $(patsubst $(o)/%,%,$@)
	$(Q)$(CC) $(LDFLAGS) -o $@ $^ $(BUILD_LDFLAGS) $(LIBS) $(LDFLAGS) $($(@F)_ldflags)

%.a:
	$(Q)mkdir -p $(dir $@)
	$(M)AR   $(patsubst $(o)/%,%,$@)
	$(Q)rm -f $@
	$(Q)ar rcs $@ $^

%.so:
	$(Q)mkdir -p $(dir $@)
	$(M)LD   $(patsubst $(o)/%,%,$@)
	$(Q)$(CC) $(LDFLAGS) -shared -o $@ $^ $(LIBS) $(LDFLAGS) $(BUILD_LDFLAGS)

deps:
	$(Q)rm -f $(o)/.deps
	$(Q)mkdir -p $(o)
	$(Q)find $(o)/ -name "*.d" -exec cat {} \; > $(o)/.deps

-include $(o)/.deps

define UNITTEST_template =
$(1): $$($(1)_OBJS) $$($(1)_LIBS:%=-l%)
ALL_OBJS   += $$($(1)_OBJS)
endef

.force:

configure: $(o)/.config
$(o)/.config: .force
	$(Q)mkdir -p $(o)
	$(Q)touch $(o)/.config
	
.PHONY: configure .force depend


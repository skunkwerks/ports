# Included after the configured emulator Makefile. Keep the link order identical
# to OTP's beam.smp rule; only the output path and extra NIF inputs are deferred.
.PHONY: export-native-sdk
export-native-sdk:
	$(CC) $(CFLAGS) $(INCLUDES) -E -P "$(SDK_SOURCE)" -o "$(SDK_DIR)/driver_tab.i"
	@printf '%s\0' $(EMU_LD) $(PROFILE_LDFLAGS) $(LDFLAGS) $(EMU_LDFLAGS) $(DEXPORT) $(INIT_OBJS) $(OBJS) NATIVE_INPUTS $(STATIC_NIF_LIBS) $(STATIC_DRIVER_LIBS) $(LIBS) > "$(SDK_DIR)/link.argv"

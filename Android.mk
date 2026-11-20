#
# SPDX-FileCopyrightText: The LineageOS Project
# SPDX-License-Identifier: Apache-2.0
#

LOCAL_PATH := $(call my-dir)

ifeq ($(TARGET_DEVICE),monterey)
include $(call all-subdir-makefiles,$(LOCAL_PATH))

# The Wi-Fi driver reads its config from the firmware folder. Stock links it
# to the copy in /vendor/etc/wifi (a symlink extract-files can't copy).
WCNSS_INI_SYMLINK := $(TARGET_OUT_VENDOR)/firmware/wlan/qca_cld/WCNSS_qcom_cfg.ini
$(WCNSS_INI_SYMLINK):
	@mkdir -p $(dir $@)
	$(hide) ln -sf /vendor/etc/wifi/WCNSS_qcom_cfg.ini $@

ALL_DEFAULT_INSTALLED_MODULES += $(WCNSS_INI_SYMLINK)
endif

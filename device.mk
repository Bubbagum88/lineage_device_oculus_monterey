#
# SPDX-FileCopyrightText: The LineageOS Project
# SPDX-License-Identifier: Apache-2.0
#

# A/B
# The boot control HAL (boot@1.0 + bootctrl.msm8998) comes from the stock
# blobs; boot@1.1/1.2 do not exist in Android 10.
PRODUCT_PACKAGES += \
    update_engine \
    update_engine_sideload \
    update_verifier

AB_OTA_POSTINSTALL_CONFIG += \
    RUN_POSTINSTALL_system=true \
    POSTINSTALL_PATH_system=system/bin/otapreopt_script \
    FILESYSTEM_TYPE_system=ext4 \
    POSTINSTALL_OPTIONAL_system=true

PRODUCT_PACKAGES += \
    checkpoint_gc \
    otapreopt_script

# AOSP HALs and libraries
# Stock ships these as plain AOSP builds. LineageOS builds the same modules at
# the same paths, so they come from source instead of the blob list.
PRODUCT_PACKAGES += \
    android.hardware.atrace@1.0-service \
    android.hardware.audio@2.0-service \
    android.hardware.audio@5.0-impl \
    android.hardware.audio.effect@5.0-impl \
    android.hardware.boot@1.0-impl \
    android.hardware.boot@1.0-service \
    android.hardware.drm@1.0-impl \
    android.hardware.drm@1.0-service \
    android.hardware.drm@1.2-service.clearkey \
    android.hardware.gatekeeper@1.0-impl \
    android.hardware.gatekeeper@1.0-service \
    android.hardware.graphics.allocator@2.0-impl \
    android.hardware.graphics.allocator@2.0-service \
    android.hardware.keymaster@3.0-impl \
    android.hardware.keymaster@3.0-service \
    android.hardware.memtrack@1.0-impl \
    android.hardware.memtrack@1.0-service \
    android.hardware.renderscript@1.0-impl \
    android.hardware.soundtrigger@2.2-impl \
    android.hardware.wifi@1.0-service \
    audio.primary.default \
    audio.r_submix.default \
    audio.usb.default \
    local_time.default

# Needed by stock blobs: libhwc2onfbadapter (composer@2.1-service.monterey),
# libjson (pd-mapper), libcld80211 (cnss-daemon).
PRODUCT_PACKAGES += \
    libcld80211 \
    libhwc2onfbadapter \
    libjson

# Wi-Fi (see BoardConfig.mk)
PRODUCT_PACKAGES += \
    hostapd \
    libwifi-hal-qcom \
    libwpa_client \
    wpa_cli \
    wpa_supplicant

# API levels
PRODUCT_SHIPPING_API_LEVEL := 25

# Health
# Provided by the stock blob android.hardware.health@2.0-service.monterey;
# health@2.1 does not exist in Android 10.

# Overlays
PRODUCT_ENFORCE_RRO_TARGETS := *

# Product characteristics
PRODUCT_CHARACTERISTICS := nosdcard

# Rootdir
PRODUCT_PACKAGES += \
    fstab.monterey \
    init.monterey.rc \
    init.monterey.usb.rc \
    init.recovery.monterey.rc \
    init.recovery.oculus.rc \
    ueventd.monterey.rc

# Soong namespaces
PRODUCT_SOONG_NAMESPACES += \
    $(LOCAL_PATH)

# Inherit the proprietary files
$(call inherit-product, vendor/oculus/monterey/monterey-vendor.mk)

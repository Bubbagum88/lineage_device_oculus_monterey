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

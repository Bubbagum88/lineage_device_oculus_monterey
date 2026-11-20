#
# SPDX-FileCopyrightText: The LineageOS Project
# SPDX-License-Identifier: Apache-2.0
#

DEVICE_PATH := device/oculus/monterey

# A/B
AB_OTA_UPDATER := true
AB_OTA_PARTITIONS += \
    boot \
    system
BOARD_USES_RECOVERY_AS_BOOT := true

# Architecture
TARGET_ARCH := arm64
TARGET_ARCH_VARIANT := armv8-a
TARGET_CPU_ABI := arm64-v8a
TARGET_CPU_ABI2 := 
TARGET_CPU_VARIANT := generic
TARGET_CPU_VARIANT_RUNTIME := generic

TARGET_2ND_ARCH := arm
TARGET_2ND_ARCH_VARIANT := armv7-a-neon
TARGET_2ND_CPU_ABI := armeabi-v7a
TARGET_2ND_CPU_ABI2 := armeabi
TARGET_2ND_CPU_VARIANT := generic
TARGET_2ND_CPU_VARIANT_RUNTIME := cortex-a53

# APEX
OVERRIDE_TARGET_FLATTEN_APEX := true

# Bootloader
TARGET_BOOTLOADER_BOARD_NAME := monterey
TARGET_NO_BOOTLOADER := true

# Display
TARGET_SCREEN_DENSITY := 235

# Kernel
BOARD_KERNEL_BASE := 0x00000000
BOARD_KERNEL_CMDLINE := androidboot.configfs=true androidboot.hardware=monterey ehci-hcd.park=3 lpm_levels.sleep_disabled=1 msm_rtb.filter=0x237 sched_enable_hmp=1 sched_enable_power_aware=1 service_locator.enable=1 softdog.soft_panic=1 swiotlb=2048 user_debug=31 bootver=1596585601 cursysver=1596585601 minsysver=1 androidboot.selinux=permissive
# Bring-up only: permissive SELinux until a sepolicy exists. Only honoured on
# userdebug/eng builds. Dropped from the stock cmdline: buildvariant=user and
# Meta's dm-verity key id (our system image is not signed with Meta's key).
BOARD_KERNEL_PAGESIZE := 4096
BOARD_KERNEL_IMAGE_NAME := Image.gz-dtb
TARGET_KERNEL_CONFIG := monterey_defconfig
TARGET_KERNEL_SOURCE := kernel/oculus/monterey

# Kernel - prebuilt
TARGET_FORCE_PREBUILT_KERNEL := true
ifeq ($(TARGET_FORCE_PREBUILT_KERNEL),true)
TARGET_PREBUILT_KERNEL := $(DEVICE_PATH)/prebuilts/kernel
endif

# Partitions
BOARD_BUILD_SYSTEM_ROOT_IMAGE := true
BOARD_FLASH_BLOCK_SIZE := 262144 # (BOARD_KERNEL_PAGESIZE * 64)
# Sizes measured on a Quest 1 with `blockdev --getsize64` (boot_a, system_a),
# matching the openquest project's values. Decimal: the build reads them with
# int(s, 10).
BOARD_BOOTIMAGE_PARTITION_SIZE := 67108864        # 0x4000000
BOARD_SYSTEMIMAGE_PARTITION_SIZE := 2684354560    # 0xA0000000
BOARD_SYSTEMIMAGE_FILE_SYSTEM_TYPE := ext4

# No vendor partition on the Quest 1: /vendor is a symlink into /system.
TARGET_COPY_OUT_VENDOR := system/vendor

# Platform
TARGET_BOARD_PLATFORM := msm8998
# Keep AOSP's hardware/qcom/* out of the build (its camera HAL needs CAF
# include paths).
BOARD_USES_QCOM_HARDWARE := true
# Display, audio and media HALs (hwcomposer.msm8998, gralloc, audio.primary,
# OMX) all come from the stock blobs, so LineageOS's msm8998 CAF source trees
# are not built: leaving them in defines modules with the same names as the
# blobs, and hwcomposer.msm8998 fails its dependency check (no libmemalloc).
QCOM_SOONG_NAMESPACE :=

# Wi-Fi
# LineageOS always defines libwifi-hal and the Wi-Fi HAL service, so they can't
# be blobs, and the Qualcomm Wi-Fi HAL it builds them against needs
# libwpa_client from wpa_supplicant_8. So the whole Wi-Fi userspace (HAL,
# wpa_supplicant, hostapd) is built from source, as on other msm8998 devices.
# The stock driver config files (WCNSS_qcom_cfg.ini, wpa_supplicant*.conf) and
# init.monterey.rc's wpa_supplicant service stay as they are.
BOARD_HAS_QCOM_WLAN := true
BOARD_WLAN_DEVICE := qcwcn
BOARD_HOSTAPD_DRIVER := NL80211
BOARD_HOSTAPD_PRIVATE_LIB := lib_driver_cmd_$(BOARD_WLAN_DEVICE)
BOARD_WPA_SUPPLICANT_DRIVER := NL80211
BOARD_WPA_SUPPLICANT_PRIVATE_LIB := lib_driver_cmd_$(BOARD_WLAN_DEVICE)
WIFI_HIDL_FEATURE_DUAL_INTERFACE := true
WPA_SUPPLICANT_VERSION := VER_0_8_X

# Properties
TARGET_SYSTEM_PROP += $(DEVICE_PATH)/system.prop
TARGET_VENDOR_PROP += $(DEVICE_PATH)/vendor.prop

# Recovery
TARGET_RECOVERY_FSTAB := $(DEVICE_PATH)/rootdir/etc/fstab.monterey
TARGET_RECOVERY_PIXEL_FORMAT := RGBX_8888
TARGET_USERIMAGES_USE_EXT4 := true
TARGET_USERIMAGES_USE_F2FS := true

# VINTF
DEVICE_MANIFEST_FILE += $(DEVICE_PATH)/manifest.xml

# Inherit the proprietary files
include vendor/oculus/monterey/BoardConfigVendor.mk

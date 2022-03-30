#
# Copyright (C) 2016 The Android Open-Source Project
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#      http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

COMMON_PATH := device/google/wahoo

TARGET_BOARD_PLATFORM := msm8998

TARGET_ARCH := arm64
TARGET_ARCH_VARIANT := armv8-a
TARGET_CPU_ABI := arm64-v8a
TARGET_CPU_ABI2 :=
TARGET_CPU_VARIANT := cortex-a73

TARGET_2ND_ARCH := arm
TARGET_2ND_ARCH_VARIANT := armv8-a
TARGET_2ND_CPU_ABI := armeabi-v7a
TARGET_2ND_CPU_ABI2 := armeabi
TARGET_2ND_CPU_VARIANT := cortex-a73

BUILD_BROKEN_DUP_RULES := true
BUILD_BROKEN_ELF_PREBUILT_PRODUCT_COPY_FILES := true
BUILD_BROKEN_USES_BUILD_COPY_HEADERS := true
BUILD_BROKEN_ENFORCE_SYSPROP_OWNER := true

# Inline kernel building configs
TARGET_KERNEL_CLANG_COMPILE := true
TARGET_KERNEL_SOURCE := kernel/google/wahoo
TARGET_KERNEL_CONFIG := wahoo_defconfig
TARGET_KERNEL_ARCH := arm64
BOARD_KERNEL_IMAGE_NAME := Image.lz4-dtb
TARGET_KERNEL_ADDITIONAL_FLAGS := \
    DTC=$(shell pwd)/prebuilts/misc/$(HOST_OS)-x86/dtc/dtc \
    MKDTIMG=$(shell pwd)/prebuilts/misc/$(HOST_OS)-x86/libufdt/mkdtimg

BOARD_KERNEL_CMDLINE += androidboot.hardware=$(TARGET_BOOTLOADER_BOARD_NAME) androidboot.console=ttyMSM0 lpm_levels.sleep_disabled=1
BOARD_KERNEL_CMDLINE += user_debug=31 msm_rtb.filter=0x37 ehci-hcd.park=3
BOARD_KERNEL_CMDLINE += service_locator.enable=1
BOARD_KERNEL_CMDLINE += swiotlb=2048
BOARD_KERNEL_CMDLINE += firmware_class.path=/vendor/firmware
BOARD_KERNEL_CMDLINE += loop.max_part=7
BOARD_KERNEL_CMDLINE += raid=noautodetect
BOARD_KERNEL_CMDLINE += usbcore.autosuspend=7

BOARD_KERNEL_BASE        := 0x00000000
BOARD_KERNEL_PAGESIZE    := 4096
ifeq ($(filter-out walleye_kasan, muskie_kasan, $(TARGET_PRODUCT)),)
BOARD_KERNEL_OFFSET      := 0x80000
BOARD_KERNEL_TAGS_OFFSET := 0x02500000
BOARD_RAMDISK_OFFSET     := 0x02700000
BOARD_MKBOOTIMG_ARGS     := --kernel_offset $(BOARD_KERNEL_OFFSET) --ramdisk_offset $(BOARD_RAMDISK_OFFSET) --tags_offset $(BOARD_KERNEL_TAGS_OFFSET)
else
BOARD_KERNEL_TAGS_OFFSET := 0x01E00000
BOARD_RAMDISK_OFFSET     := 0x02000000
endif

TARGET_NO_BOOTLOADER ?= true
TARGET_NO_KERNEL := false
TARGET_NO_RECOVERY := true
BOARD_USES_RECOVERY_AS_BOOT := true
#BOARD_BUILD_SYSTEM_ROOT_IMAGE := true
BOARD_USES_METADATA_PARTITION := true

# Partitions (listed in the file) to be wiped under recovery.
TARGET_RECOVERY_WIPE := device/google/wahoo/recovery.wipe
TARGET_RECOVERY_FSTAB := device/google/wahoo/rootdir/etc/fstab.hardware

# Verified Boot
BOARD_AVB_ENABLE := true
BOARD_AVB_MAKE_VBMETA_IMAGE_ARGS += --flags 3

# product.img
ifneq ($(PRODUCT_NO_PRODUCT_PARTITION), true)
ifneq ($(PRODUCT_USE_DYNAMIC_PARTITIONS), true)
  BOARD_PRODUCTIMAGE_PARTITION_SIZE := 314572800
endif
BOARD_PRODUCTIMAGE_FILE_SYSTEM_TYPE := ext4
else
TARGET_COPY_OUT_PRODUCT := system/product
endif

BOARD_PRODUCTIMAGE_SIZE := 4266131456
BOARD_PRODUCTIMAGE_FILE_SYSTEM_TYPE := ext4

# system.img
ifneq ($(PRODUCT_USE_DYNAMIC_PARTITIONS), true)
  BOARD_SYSTEMIMAGE_PARTITION_SIZE := 2684354560
ifeq ($(PRODUCT_NO_PRODUCT_PARTITION), true)
  # Increase inode count to add product modules
  BOARD_SYSTEMIMAGE_EXTFS_INODE_COUNT := 8192
else
  BOARD_SYSTEMIMAGE_EXTFS_INODE_COUNT := 4096
endif
endif
BOARD_SYSTEMIMAGE_JOURNAL_SIZE := 0

# userdata.img
TARGET_USERIMAGES_USE_EXT4 := true
BOARD_USERDATAIMAGE_PARTITION_SIZE := 26503790080

# persist.img
BOARD_PERSISTIMAGE_PARTITION_SIZE := 33554432
BOARD_PERSISTIMAGE_FILE_SYSTEM_TYPE := ext4

# system_ext.img
ifneq ($(PRODUCT_USE_DYNAMIC_PARTITIONS), true)
TARGET_COPY_OUT_SYSTEM_EXT := system/system_ext
else
BOARD_SYSTEM_EXTIMAGE_FILE_SYSTEM_TYPE := ext4
endif
ifeq ($(PRODUCT_NO_PRODUCT_PARTITION), true)
# no system_ext partition as well
TARGET_COPY_OUT_SYSTEM_EXT := system/system_ext
endif

# vendor.img
BOARD_VENDORIMAGE_PARTITION_SIZE := 524288000
BOARD_VENDORIMAGE_FILE_SYSTEM_TYPE := ext4

BOARD_FLASH_BLOCK_SIZE := 131072

# dtbo.img
TARGET_NEEDS_DTBOIMAGE := true
BOARD_DTBOIMG_PARTITION_SIZE := 8388608

ifeq ($(PRODUCT_USE_DYNAMIC_PARTITIONS), true)
BOARD_SUPER_PARTITION_GROUPS := google_dynamic_partitions
BOARD_GOOGLE_DYNAMIC_PARTITIONS_PARTITION_LIST := \
    system \
    vendor \
    product \
    system_ext

ifeq ($(PRODUCT_RETROFIT_DYNAMIC_PARTITIONS), true)
# Pixel 2 devices require retrofit.
BOARD_SUPER_PARTITION_SIZE := 7474778112
BOARD_SUPER_PARTITION_METADATA_DEVICE := system
BOARD_SUPER_PARTITION_BLOCK_DEVICES := system vendor product
BOARD_SUPER_PARTITION_SYSTEM_DEVICE_SIZE := 2684354560
BOARD_SUPER_PARTITION_VENDOR_DEVICE_SIZE := 524288000
BOARD_SUPER_PARTITION_PRODUCT_DEVICE_SIZE := 4266135552
# Assume 4MB metadata size.
BOARD_GOOGLE_DYNAMIC_PARTITIONS_SIZE := 4069523456
endif # PRODUCT_RETROFIT_DYNAMIC_PARTITIONS
endif # PRODUCT_USE_DYNAMIC_PARTITIONS

TARGET_COPY_OUT_VENDOR := vendor

TARGET_COPY_OUT_PRODUCT := product

TARGET_COPY_OUT_SYSTEM_EXT := system_ext

# Install odex files into the other system image
BOARD_USES_SYSTEM_OTHER_ODEX := true

BOARD_ROOT_EXTRA_FOLDERS := persist firmware metadata

BOARD_VENDOR_SEPOLICY_DIRS += device/google/wahoo/sepolicy/vendor
SYSTEM_EXT_PUBLIC_SEPOLICY_DIRS := device/google/wahoo/sepolicy/public
SYSTEM_EXT_PRIVATE_SEPOLICY_DIRS := device/google/wahoo/sepolicy/private
BOARD_VENDOR_SEPOLICY_DIRS += device/google/wahoo/sepolicy/verizon
BOARD_VENDOR_SEPOLICY_DIRS += hardware/google/pixel-sepolicy/citadel
BOARD_VENDOR_SEPOLICY_DIRS += hardware/google/pixel-sepolicy/powerstats

TARGET_FS_CONFIG_GEN := device/google/wahoo/config.fs

QCOM_BOARD_PLATFORMS += msm8998
BOARD_HAVE_BLUETOOTH_QCOM := true
BOARD_USES_SDM845_BLUETOOTH_HAL := true
BOARD_BLUETOOTH_BDROID_BUILDCFG_INCLUDE_DIR := device/google/wahoo/bluetooth

# Camera
TARGET_USES_AOSP := true
BOARD_QTI_CAMERA_32BIT_ONLY := true
CAMERA_DAEMON_NOT_PRESENT := true
TARGET_USES_ION := true
TARGET_USES_EASEL := true
BOARD_USES_EASEL := true

# GPS
TARGET_NO_RPC := true
BOARD_VENDOR_QCOM_GPS_LOC_API_HARDWARE := default
BOARD_VENDOR_QCOM_LOC_PDK_FEATURE_SET := true

# RenderScript
OVERRIDE_RS_DRIVER := libRSDriver_adreno.so

# wlan
BOARD_WLAN_DEVICE := qcwcn
BOARD_WPA_SUPPLICANT_DRIVER := NL80211
BOARD_HOSTAPD_DRIVER := NL80211
WIFI_DRIVER_DEFAULT := qca_cld3
WPA_SUPPLICANT_VERSION := VER_0_8_X
WIFI_DRIVER_FW_PATH_STA := "sta"
WIFI_DRIVER_FW_PATH_AP  := "ap"
WIFI_DRIVER_FW_PATH_P2P := "p2p"
BOARD_WPA_SUPPLICANT_PRIVATE_LIB := lib_driver_cmd_$(BOARD_WLAN_DEVICE)
BOARD_HOSTAPD_PRIVATE_LIB := lib_driver_cmd_$(BOARD_WLAN_DEVICE)
WIFI_HIDL_FEATURE_AWARE := true
WIFI_HIDL_UNIFIED_SUPPLICANT_SERVICE_RC_ENTRY := true
WIFI_HIDL_FEATURE_DUAL_INTERFACE := true

# CHRE
CHRE_DAEMON_ENABLED := true
CHRE_DAEMON_USE_SDSPRPC := true

# Audio
BOARD_USES_ALSA_AUDIO := true
AUDIO_FEATURE_ENABLED_MULTI_VOICE_SESSIONS := true
AUDIO_FEATURE_ENABLED_SND_MONITOR := true
AUDIO_FEATURE_ENABLED_USB_TUNNEL := true
BOARD_ROOT_EXTRA_SYMLINKS := /vendor/lib/dsp:/dsp
BOARD_SUPPORTS_SOUND_TRIGGER := true

# Include whaoo modules
USES_DEVICE_GOOGLE_WAHOO := true

# Graphics
TARGET_USES_GRALLOC1 := true
TARGET_USES_HWC2 := true

VSYNC_EVENT_PHASE_OFFSET_NS := 2000000
SF_VSYNC_EVENT_PHASE_OFFSET_NS := 6000000

# Display
TARGET_HAS_WIDE_COLOR_DISPLAY := true
TARGET_HAS_HDR_DISPLAY := true
TARGET_USES_COLOR_METADATA := true

# Vendor Interface Manifest
DEVICE_MANIFEST_FILE := device/google/wahoo/manifest.xml
DEVICE_MATRIX_FILE := device/google/wahoo/compatibility_matrix.xml
DEVICE_FRAMEWORK_MANIFEST_FILE := device/google/wahoo/framework_manifest.xml
DEVICE_FRAMEWORK_COMPATIBILITY_MATRIX_FILE := device/google/wahoo/device_framework_matrix.xml
BOARD_PROPERTY_OVERRIDES_SPLIT_ENABLED := true

BOARD_VNDK_VERSION := current

# Board uses A/B OTA.
AB_OTA_UPDATER := true

AB_OTA_PARTITIONS += \
    boot \
    system \
    vbmeta \
    dtbo \
    vendor

# Skip product and system_ext partition for nodap build
ifeq ($(filter %_nodap,$(TARGET_PRODUCT)),)
AB_OTA_PARTITIONS += \
    product \
    system_ext
endif

BUILD_BROKEN_ENFORCE_SYSPROP_OWNER := true

#
# Copyright (C) 2019-2024
#
# MediaTek MT7628 WiFi AP driver for OpenWrt 21.02
#

include $(TOPDIR)/rules.mk
include $(INCLUDE_DIR)/kernel.mk

PKG_NAME:=mt7628-mtk-ap
PKG_VERSION:=4.1.1.0
PKG_RELEASE:=1

PKG_BUILD_DIR:=$(KERNEL_BUILD_DIR)/$(PKG_NAME)-$(PKG_VERSION)

include $(INCLUDE_DIR)/package.mk

define KernelPackage/mt7628-mtk-ap
  SUBMENU:=Wireless Drivers
  TITLE:=MediaTek MT7628 WiFi AP driver (v4.1.1.0)
  DEPENDS:=@TARGET_ramips_mt76x8
  FILES:=$(PKG_BUILD_DIR)/mt7628_wifi/embedded/mt7628.ko
  AUTOLOAD:=$(call AutoProbe,mt7628)
endef

define KernelPackage/mt7628-mtk-ap/description
  MediaTek MT7628/MT7688 WiFi AP driver (official v4.1.1.0)
  This is the last official release from MediaTek (2019).
  More stable than open-source mt76 driver.
endef

define Build/Prepare
	mkdir -p $(PKG_BUILD_DIR)
	$(CP) ./mt7628_wifi $(PKG_BUILD_DIR)/
	$(Build/Patch)
endef

# Define module name and source directory relative to PKG_BUILD_DIR
DRV_NAME:=mt7628
SRC_DIR:=mt7628_wifi/embedded

# Extra CFLAGS for all source files
EXTRA_CFLAGS:= \
	-I$(PKG_BUILD_DIR)/mt7628_wifi/include \
	-I$(PKG_BUILD_DIR)/mt7628_wifi/embedded/include \
	-I$(PKG_BUILD_DIR)/mt7628_wifi/ate/include \
	-DCONFIG_SUPPORT_OPENWRT \
	-DCONFIG_MT7628_AP_SUPPORT \
	-DCONFIG_AP_SUPPORT \
	-DCONFIG_MT7628_WIFI \
	-DCONFIG_MT7628_MAC \
	-DLINUX \
	-DWIFI_MODULE \
	-DDOT11_N_SUPPORT \
	-DDOT11N_DRAFT3 \
	-DSTATS_COUNT_SUPPORT \
	-DIAPP_SUPPORT \
	-DDOT1X_SUPPORT \
	-DDOT11R_FT_SUPPORT \
	-DDOT11K_RRM_SUPPORT \
	-DAP_SCAN_SUPPORT \
	-DSCAN_SUPPORT \
	-DAPPLE_11K_IOT \
	-DMEMORY_OPTIMIZATION \
	-DMT7628 \
	-DMT_BBP \
	-DMT_RF \
	-DRTMP_RBUS_SUPPORT \
	-DRTMP_RF_RW_SUPPORT \
	-DMT_MAC \
	-DRTMP_MAC_PCI \
	-DRTMP_PCI_SUPPORT \
	-DRTMP_FLASH_SUPPORT \
	-DDMA_SCH_SUPPORT \
	-DRTMP_EFUSE_SUPPORT \
	-DCONFIG_ANDES_SUPPORT \
	-DRESOURCE_PRE_ALLOC \
	-DNEW_MBSSID_MODE \
	-DENHANCE_NEW_MBSSID_MODE \
	-DENHANCED_STAT_DISPLAY \
	-DFIFO_EXT_SUPPORT \
	-DMCS_LUT_SUPPORT \
	-DUSE_BMC \
	-DTHERMAL_PROTECT_SUPPORT \
	-DCAL_FREE_IC_SUPPORT \
	-DTRAFFIC_BASED_TXOP \
	-DDATA_QUEUE_RESERVE \
	-DEAPOL_QUEUE_SUPPORT \
	-DDMA_RESET_SUPPORT \
	-DWTBL_RATE_DEBUG \
	-DCONFIG_BA_REORDER_MONITOR \
	-DEDCCA_RB \
	-DAGGREGATION_SUPPORT \
	-DPIGGYBACK_SUPPORT \
	-DWMM_SUPPORT \
	-DIP_ASSEMBLY \
	-DCONFIG_RA_NAT_NONE \
	-DDBG \
	-DDOT11_SAE_SUPPORT \
	-DNEW_RATE_ADAPT_SUPPORT \
	-DDOT11W_PMF_SUPPORT

# Build using kernel build system
define Build/Compile
	$(MAKE) -C "$(LINUX_DIR)" \
		$(KERNEL_MAKE_FLAGS) \
		M="$(PKG_BUILD_DIR)/$(SRC_DIR)" \
		EXTRA_CFLAGS="$(EXTRA_CFLAGS)" \
		CONFIG_SUPPORT_OPENWRT=y \
		CONFIG_MT7628_AP_SUPPORT=m \
		CONFIG_MT7628_WIFI=m \
		modules
endef

$(eval $(call KernelPackage,mt7628-mtk-ap))

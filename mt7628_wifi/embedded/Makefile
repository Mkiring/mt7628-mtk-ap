# Makefile for MT7628 WiFi driver (embedded sources)
# Standard kernel module Makefile for OpenWrt

# Module definition
obj-$(CONFIG_MT7628_WIFI) += mt7628.o

# Include paths - use $(src) which points to current directory in kernel build
EXTRA_CFLAGS += \
	-I$(src)/../include \
	-I$(src)/include \
	-I$(src)/../ate/include \
	-DCONFIG_SUPPORT_OPENWRT \
	-DCONFIG_MT7628_AP_SUPPORT \
	-DCONFIG_AP_SUPPORT \
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

# Common objects
mt7628-objs := \
	common/crypt_md5.o \
	common/crypt_sha2.o \
	common/crypt_hmac.o \
	common/crypt_aes.o \
	common/crypt_arc4.o \
	common/mlme.o \
	common/cmm_wep.o \
	common/action.o \
	common/ba_action.o \
	common/cmm_data.o \
	common/rtmp_init.o \
	common/rtmp_init_inf.o \
	common/cmm_tkip.o \
	common/cmm_aes.o \
	common/cmm_sync.o \
	common/eeprom.o \
	common/cmm_sanity.o \
	common/cmm_info.o \
	common/cmm_cfg.o \
	common/cmm_wpa.o \
	common/cmm_radar.o \
	common/spectrum.o \
	common/rtmp_timer.o \
	common/rt_channel.o \
	common/rt_os_util.o \
	common/cmm_profile.o \
	common/scan.o \
	common/cmm_cmd.o \
	common/sys_log.o \
	common/txpower.o \
	common/op_class.o \
	common/vendor.o \
	common/mwds.o \
	common/routing_tab.o

# Rate control objects
mt7628-objs += \
	../rate_ctrl/ra_ctrl.o \
	../rate_ctrl/alg_legacy.o \
	../rate_ctrl/alg_grp.o

# ASIC/PHY objects
mt7628-objs += \
	../phy/phy.o \
	../hw_ctrl/cmm_asic.o \
	../chips/rtmp_chip.o

# Management objects
mt7628-objs += \
	mgmt/mgmt_ht.o \
	mgmt/mgmt_hw.o \
	mgmt/mgmt_entrytb.o

# TX/RX objects
mt7628-objs += \
	tx_rx/wdev.o \
	tx_rx/wdev_tx.o \
	tx_rx/wdev_rx.o

# OS interface objects
mt7628-objs += \
	os/linux/rt_profile.o

# AP mode objects (conditional)
ifdef CONFIG_MT7628_AP_SUPPORT
mt7628-objs += \
	ap/ap.o \
	ap/ap_assoc.o \
	ap/ap_auth.o \
	ap/ap_connect.o \
	ap/ap_mlme.o \
	ap/ap_sanity.o \
	ap/ap_sync.o \
	ap/ap_wpa.o \
	ap/ap_data.o \
	ap/ap_autoChSel.o \
	ap/ap_qload.o \
	ap/ap_cfg.o \
	ap/ap_nps.o \
	ap/ap_ftkd.o
endif

# Chip-specific objects for MT7628
mt7628-objs += \
	../chips/mt7628.o \
	../hw_ctrl/cmm_asic_mt.o \
	../hw_ctrl/cmm_chip_mt.o \
	../mac/mt_mac.o \
	mcu/mcu.o \
	mcu/andes_core.o \
	mcu/andes_mt.o \
	mcu/led.o \
	mcu/hal.o \
	../phy/mt_rf.o \
	../phy/rf.o \
	../phy/mt_phy.o \
	common/cmm_mac_pci.o \
	common/cmm_data_pci.o \
	common/ee_prom.o \
	os/linux/rt_rbus_pci_drv.o \
	hif/hif_pci.o \
	os/linux/rbus_main_dev.o

# EEPROM objects
mt7628-objs += \
	common/eeprom.o \
	common/ee_flash.o \
	common/ee_efuse.o

# Additional PCI/RBUS objects
mt7628-objs += \
	os/linux/rt_pci_rbus.o \
	os/linux/rt_rbus_pci_util.o

# Spec feature objects
mt7628-objs += \
	common/ps.o \
	common/mt_ps.o \
	common/mt_io.o \
	tx_rx/txs.o \
	common/ft.o \
	common/ft_tlv.o \
	common/ft_iocl.o \
	common/ft_rc.o \
	common/rrm.o \
	common/rrm_tlv.o \
	common/rrm_sanity.o \
	common/pmf.o \
	common/sae.o \
	common/crypt_dh.o \
	common/crypt_biginteger.o \
	common/crypt_bignum.o \
	common/bn_lib.o \
	common/ecc.o

# OS specific objects
mt7628-objs += \
	os/linux/rt_linux.o \
	os/linux/rt_main_dev.o \
	os/linux/ap_ioctl.o \
	os/linux/cfg80211/cfg80211.o \
	os/linux/cfg80211/cfg80211_util.o \
	os/linux/cfg80211/cfg80211_scan.o \
	os/linux/cfg80211/cfg80211_rx.o \
	os/linux/cfg80211/cfg80211_tx.o \
	os/linux/cfg80211/cfg80211_inf.o \
	os/linux/cfg80211/cfg80211_p2p.o \
	os/linux/cfg80211/cfg80211_ap.o \
	os/linux/cfg80211/cfg80211drv.o \
	os/linux/rt_proc.o \
	os/linux/rt_symb.o \
	os/linux/rt_rbus_pci_drv.o \

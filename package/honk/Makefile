#
# Copyright (C) 2026 ImmortalWrt MT798x
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=honk
PKG_VERSION:=0.1.0_beta4
PKG_RELEASE:=1

HONK_RELEASE:=v0.1.0-beta.4
HONK_ASSET:=honk-core-$(HONK_RELEASE)-aarch64-unknown-linux-musl-stock-native-api.tar.gz

PKG_SOURCE:=$(HONK_ASSET)
PKG_SOURCE_URL:=https://github.com/daeuniverse/honk/releases/download/$(HONK_RELEASE)/
PKG_HASH:=6dee922a25f1381e8811a4cd2c173a14bdf2448023fed1b4707d7e83ea3dd06b
PKG_BUILD_DIR:=$(BUILD_DIR)/$(PKG_NAME)-$(PKG_VERSION)

PKG_LICENSE:=GPL-3.0-only
PKG_LICENSE_FILES:=LICENSE
PKG_MAINTAINER:=honk upstream <noreply@github.com>

include $(INCLUDE_DIR)/package.mk

define Package/honk
  SECTION:=net
  CATEGORY:=Network
  SUBMENU:=Web Servers/Proxies
  TITLE:=honk - eBPF transparent proxy engine (dae-compatible)
  URL:=https://github.com/daeuniverse/honk
  DEPENDS:=@(aarch64||x86_64) \
	+ca-bundle +ip-full \
	+kmod-sched-core +kmod-sched-bpf +kmod-veth +kmod-nft-queue \
	+v2ray-geoip +v2ray-geosite \
	+@KERNEL_XDP_SOCKETS +@KERNEL_DEBUG_INFO_BTF +@KERNEL_CGROUP_BPF
endef

define Package/honk/description
 Honk is a Rust transparent proxy engine for Linux, inspired by dae for its
 eBPF datapath and configuration surface, and by sing-box for its outbound
 groups, multi-protocol dialers, and Clash-compatible API.

 This package ships the upstream aarch64 static musl binary (native-api
 variant) and installs the init script and default dae-style configuration.
endef

define Package/honk/conffiles
/etc/config/honk
/etc/honk/config.dae
/etc/honk/config.d/
endef

define Build/Prepare
	mkdir -p $(PKG_BUILD_DIR)
	$(TAR) -xzf $(DL_DIR)/$(PKG_SOURCE) -C $(PKG_BUILD_DIR) --strip-components=1
endef

define Build/Compile
endef

define Package/honk/install
	$(INSTALL_DIR) $(1)/usr/bin
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/honk-core $(1)/usr/bin/honk-core

	$(INSTALL_DIR) $(1)/etc/config
	$(INSTALL_CONF) $(CURDIR)/files/honk.config $(1)/etc/config/honk

	$(INSTALL_DIR) $(1)/etc/init.d
	$(INSTALL_BIN) $(CURDIR)/files/honk.init $(1)/etc/init.d/honk

	$(INSTALL_DIR) $(1)/etc/honk/config.d
	$(INSTALL_CONF) $(CURDIR)/files/config.dae $(1)/etc/honk/config.dae
	$(INSTALL_CONF) $(CURDIR)/files/config.d/*.dae $(1)/etc/honk/config.d/

	$(INSTALL_DIR) $(1)/usr/share/licenses/honk
	$(INSTALL_DATA) $(PKG_BUILD_DIR)/LICENSE $(1)/usr/share/licenses/honk/LICENSE
endef

$(eval $(call BuildPackage,honk))

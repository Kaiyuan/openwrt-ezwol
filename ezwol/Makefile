include $(TOPDIR)/rules.mk

PKG_NAME:=ezwol
PKG_VERSION:=1.0.0
PKG_RELEASE:=1

PKG_MAINTAINER:=Your Name <your.email@example.com>
PKG_LICENSE:=MIT

include $(INCLUDE_DIR)/package.mk

define Package/ezwol
  SECTION:=net
  CATEGORY:=Network
  TITLE:=Easy Wake-on-LAN service
  DEPENDS:=+etherwake +socat +luci-base
  PKGARCH:=all
endef

define Package/ezwol/description
  A simple service that listens for MAC addresses on a network port
  and sends Wake-on-LAN magic packets to wake up devices on the LAN.
  Includes authentication and a LuCI web interface for configuration.
endef

define Package/ezwol/conffiles
/etc/config/ezwol
endef

define Build/Compile
endef

define Package/ezwol/install
	$(INSTALL_DIR) $(1)/etc/config
	$(INSTALL_CONF) ./files/ezwol.config $(1)/etc/config/ezwol
	
	$(INSTALL_DIR) $(1)/etc/init.d
	$(INSTALL_BIN) ./files/ezwol.init $(1)/etc/init.d/ezwol
	
	$(INSTALL_DIR) $(1)/usr/sbin
	$(INSTALL_BIN) ./files/ezwold.sh $(1)/usr/sbin/ezwold
	
	$(INSTALL_DIR) $(1)/usr/lib/lua/luci/controller
	$(INSTALL_DATA) ./luasrc/controller/ezwol.lua $(1)/usr/lib/lua/luci/controller/
	
	$(INSTALL_DIR) $(1)/usr/lib/lua/luci/model/cbi
	$(INSTALL_DATA) ./luasrc/model/cbi/ezwol.lua $(1)/usr/lib/lua/luci/model/cbi/
	
	$(INSTALL_DIR) $(1)/usr/lib/lua/luci/view/ezwol
	$(INSTALL_DATA) ./luasrc/view/ezwol/usage.htm $(1)/usr/lib/lua/luci/view/ezwol/
	
	$(INSTALL_DIR) $(1)/usr/lib/lua/luci/i18n
	po2lmo ./po/zh_Hans/ezwol.po $(1)/usr/lib/lua/luci/i18n/ezwol.zh-cn.lmo 2>/dev/null || true
endef

$(eval $(call BuildPackage,ezwol))

#!/bin/bash
# EzWoL IPK 打包脚本
# 用于快速创建 IPK 安装包（无需完整 OpenWRT SDK）

set -e

PACKAGE_NAME="ezwol"
VERSION="1.0.0"
RELEASE="1"
ARCH="all"
BUILD_DIR="build"
PACKAGE_DIR="${BUILD_DIR}/${PACKAGE_NAME}_${VERSION}-${RELEASE}"

echo "========================================"
echo "EzWoL IPK 打包工具"
echo "========================================"

# 清理旧的构建
echo "清理旧的构建文件..."
rm -rf ${BUILD_DIR}
mkdir -p ${PACKAGE_DIR}

# 创建目录结构
echo "创建目录结构..."
mkdir -p ${PACKAGE_DIR}/etc/config
mkdir -p ${PACKAGE_DIR}/etc/init.d
mkdir -p ${PACKAGE_DIR}/usr/sbin
mkdir -p ${PACKAGE_DIR}/usr/lib/lua/luci/controller
mkdir -p ${PACKAGE_DIR}/usr/lib/lua/luci/model/cbi
mkdir -p ${PACKAGE_DIR}/usr/lib/lua/luci/view/ezwol
mkdir -p ${PACKAGE_DIR}/CONTROL

# 复制文件
echo "复制文件..."
cp ezwol/files/ezwol.config ${PACKAGE_DIR}/etc/config/ezwol
cp ezwol/files/ezwol.init ${PACKAGE_DIR}/etc/init.d/ezwol
cp ezwol/files/ezwold.sh ${PACKAGE_DIR}/usr/sbin/ezwold
cp ezwol/luasrc/controller/ezwol.lua ${PACKAGE_DIR}/usr/lib/lua/luci/controller/
cp ezwol/luasrc/model/cbi/ezwol.lua ${PACKAGE_DIR}/usr/lib/lua/luci/model/cbi/
cp ezwol/luasrc/view/ezwol/usage.htm ${PACKAGE_DIR}/usr/lib/lua/luci/view/ezwol/

# 设置权限
echo "设置文件权限..."
chmod 755 ${PACKAGE_DIR}/etc/init.d/ezwol
chmod 755 ${PACKAGE_DIR}/usr/sbin/ezwold
chmod 644 ${PACKAGE_DIR}/etc/config/ezwol
chmod 644 ${PACKAGE_DIR}/usr/lib/lua/luci/controller/ezwol.lua
chmod 644 ${PACKAGE_DIR}/usr/lib/lua/luci/model/cbi/ezwol.lua
chmod 644 ${PACKAGE_DIR}/usr/lib/lua/luci/view/ezwol/usage.htm

# 创建 control 文件
echo "创建 control 文件..."
cat > ${PACKAGE_DIR}/CONTROL/control << EOF
Package: ${PACKAGE_NAME}
Version: ${VERSION}-${RELEASE}
Depends: etherwake, socat
Section: net
Category: Network
Architecture: ${ARCH}
Maintainer: EzWoL Team
Description: Easy Wake-on-LAN service
 A simple service that listens for MAC addresses on a network port
 and sends Wake-on-LAN magic packets to wake up devices on the LAN.
 Includes authentication and a LuCI web interface for configuration.
EOF

# 创建 conffiles
echo "创建 conffiles..."
cat > ${PACKAGE_DIR}/CONTROL/conffiles << EOF
/etc/config/ezwol
EOF

# 创建 postinst 脚本（安装后执行）
echo "创建 postinst 脚本..."
cat > ${PACKAGE_DIR}/CONTROL/postinst << 'EOF'
#!/bin/sh
[ -n "${IPKG_INSTROOT}" ] || {
    ( . /etc/uci-defaults/luci-ezwol ) && rm -f /etc/uci-defaults/luci-ezwol
    /etc/init.d/ezwol enable
    echo "EzWoL installed successfully!"
    echo "Please configure it via LuCI: Services -> EzWoL"
}
exit 0
EOF
chmod 755 ${PACKAGE_DIR}/CONTROL/postinst

# 创建 prerm 脚本（卸载前执行）
echo "创建 prerm 脚本..."
cat > ${PACKAGE_DIR}/CONTROL/prerm << 'EOF'
#!/bin/sh
[ -n "${IPKG_INSTROOT}" ] || {
    /etc/init.d/ezwol stop
    /etc/init.d/ezwol disable
}
exit 0
EOF
chmod 755 ${PACKAGE_DIR}/CONTROL/prerm

# 计算安装大小
INSTALLED_SIZE=$(du -sb ${PACKAGE_DIR} | cut -f1)
echo "Installed-Size: ${INSTALLED_SIZE}" >> ${PACKAGE_DIR}/CONTROL/control

# 打包
echo "打包 IPK..."
cd ${BUILD_DIR}

# 创建 data.tar.gz
tar czf data.tar.gz -C ${PACKAGE_NAME}_${VERSION}-${RELEASE} \
    --exclude=CONTROL \
    .

# 创建 control.tar.gz
tar czf control.tar.gz -C ${PACKAGE_NAME}_${VERSION}-${RELEASE}/CONTROL \
    .

# 创建 debian-binary
echo "2.0" > debian-binary

# 创建最终的 IPK
IPK_NAME="${PACKAGE_NAME}_${VERSION}-${RELEASE}_${ARCH}.ipk"
tar czf ${IPK_NAME} debian-binary control.tar.gz data.tar.gz

# 清理临时文件
rm -f debian-binary control.tar.gz data.tar.gz
rm -rf ${PACKAGE_NAME}_${VERSION}-${RELEASE}

cd ..

echo "========================================"
echo "✓ 打包完成！"
echo "========================================"
echo "IPK 文件: ${BUILD_DIR}/${IPK_NAME}"
echo ""
echo "安装方法："
echo "  1. 复制到路由器: scp ${BUILD_DIR}/${IPK_NAME} root@192.168.1.1:/tmp/"
echo "  2. SSH 登录路由器: ssh root@192.168.1.1"
echo "  3. 安装: opkg install /tmp/${IPK_NAME}"
echo ""
echo "或使用部署脚本："
echo "  ./deploy-ipk.sh root@192.168.1.1"
echo "========================================"

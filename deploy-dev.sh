#!/bin/bash
# EzWoL 开发部署脚本 - 直接复制文件到路由器（用于开发测试）

if [ $# -ne 1 ]; then
    echo "用法: $0 <路由器地址>"
    echo "示例: $0 root@192.168.1.1"
    exit 1
fi

ROUTER="$1"

echo "========================================"
echo "EzWoL 开发部署工具"
echo "========================================"
echo "目标路由器: $ROUTER"
echo ""
echo "警告: 此脚本直接复制文件，仅用于开发测试！"
echo "生产环境请使用: ./build-ipk.sh && ./deploy-ipk.sh"
echo ""
read -p "继续? (y/N) " -n 1 -r
echo
if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    exit 0
fi

echo ""
echo "1. 创建目录结构..."
ssh "$ROUTER" "mkdir -p /etc/config /etc/init.d /usr/sbin /usr/lib/lua/luci/controller /usr/lib/lua/luci/model/cbi /usr/lib/lua/luci/view/ezwol"

echo "2. 复制配置文件..."
scp ezwol/files/ezwol.config "$ROUTER:/etc/config/ezwol"

echo "3. 复制 init 脚本..."
scp ezwol/files/ezwol.init "$ROUTER:/etc/init.d/ezwol"
ssh "$ROUTER" "chmod 755 /etc/init.d/ezwol"

echo "4. 复制守护进程..."
scp ezwol/files/ezwold.sh "$ROUTER:/usr/sbin/ezwold"
ssh "$ROUTER" "chmod 755 /usr/sbin/ezwold"

echo "5. 复制 LuCI 文件..."
scp ezwol/luasrc/controller/ezwol.lua "$ROUTER:/usr/lib/lua/luci/controller/"
scp ezwol/luasrc/model/cbi/ezwol.lua "$ROUTER:/usr/lib/lua/luci/model/cbi/"
scp ezwol/luasrc/view/ezwol/usage.htm "$ROUTER:/usr/lib/lua/luci/view/ezwol/"

echo "6. 清除 LuCI 缓存..."
ssh "$ROUTER" "rm -rf /tmp/luci-*"

echo ""
echo "========================================"
echo "✓ 开发部署完成！"
echo "========================================"
echo ""
echo "下一步："
echo "  1. 刷新 LuCI 界面 (Ctrl+F5)"
echo "  2. 导航到: 服务 -> EzWoL"
echo "  3. 配置并启用服务"
echo ""
echo "查看日志:"
echo "  ssh $ROUTER 'logread -f | grep ezwold'"
echo ""
echo "重启服务:"
echo "  ssh $ROUTER '/etc/init.d/ezwol restart'"
echo "========================================"

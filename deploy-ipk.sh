#!/bin/bash
# EzWoL 部署脚本 - 将 IPK 包部署到路由器

if [ $# -ne 1 ]; then
    echo "用法: $0 <路由器地址>"
    echo "示例: $0 root@192.168.1.1"
    exit 1
fi

ROUTER="$1"
IPK_FILE=$(ls build/ezwol_*.ipk 2>/dev/null | head -n 1)

if [ -z "$IPK_FILE" ]; then
    echo "错误: 未找到 IPK 文件"
    echo "请先运行: ./build-ipk.sh"
    exit 1
fi

echo "========================================"
echo "EzWoL 部署工具"
echo "========================================"
echo "目标路由器: $ROUTER"
echo "IPK 文件: $IPK_FILE"
echo ""

# 复制 IPK 到路由器
echo "1. 复制 IPK 到路由器..."
scp "$IPK_FILE" "$ROUTER:/tmp/" || {
    echo "错误: 无法复制文件到路由器"
    exit 1
}

# 安装
echo ""
echo "2. 安装插件..."
ssh "$ROUTER" "opkg install /tmp/$(basename $IPK_FILE)" || {
    echo "错误: 安装失败"
    exit 1
}

echo ""
echo "========================================"
echo "✓ 部署完成！"
echo "========================================"
echo ""
echo "下一步："
echo "  1. 访问路由器 LuCI 界面"
echo "  2. 导航到: 服务 -> EzWoL"
echo "  3. 生成认证密钥并启用服务"
echo ""
echo "或通过命令行配置："
echo "  ssh $ROUTER"
echo "  uci set ezwol.config.enabled='1'"
echo "  uci set ezwol.config.auth_key='your-key-here'"
echo "  uci commit ezwol"
echo "  /etc/init.d/ezwol start"
echo "========================================"

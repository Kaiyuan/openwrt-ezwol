#!/bin/bash
# Git 初始化和推送脚本

echo "========================================"
echo "EzWoL GitHub 初始化脚本"
echo "========================================"
echo ""

# 检查是否已经是 Git 仓库
if [ -d ".git" ]; then
    echo "检测到已存在的 Git 仓库"
    read -p "是否要重新初始化? (y/N) " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        rm -rf .git
        echo "已删除旧的 Git 仓库"
    else
        echo "保留现有 Git 仓库"
    fi
fi

# 获取 GitHub 仓库地址
echo ""
echo "请输入您的 GitHub 仓库地址"
echo "格式: https://github.com/username/openwrt-ezwol.git"
read -p "仓库地址: " REPO_URL

if [ -z "$REPO_URL" ]; then
    echo "错误: 仓库地址不能为空"
    exit 1
fi

# 初始化 Git
echo ""
echo "1. 初始化 Git 仓库..."
git init

# 添加所有文件
echo "2. 添加文件到 Git..."
git add .

# 提交
echo "3. 创建初始提交..."
git commit -m "Initial commit: EzWoL OpenWRT Wake-on-LAN plugin

- Complete OpenWRT package structure
- LuCI web interface with authentication
- Random key generation
- Service status monitoring
- Multi-architecture support
- GitHub Actions for automatic builds
- Comprehensive documentation"

# 设置主分支
echo "4. 设置主分支为 main..."
git branch -M main

# 添加远程仓库
echo "5. 添加远程仓库..."
git remote add origin "$REPO_URL"

# 推送到 GitHub
echo "6. 推送到 GitHub..."
echo ""
read -p "是否现在推送到 GitHub? (Y/n) " -n 1 -r
echo
if [[ ! $REPLY =~ ^[Nn]$ ]]; then
    git push -u origin main
    
    echo ""
    echo "========================================"
    echo "✓ 推送成功！"
    echo "========================================"
    echo ""
    echo "下一步："
    echo "  1. 访问: $REPO_URL"
    echo "  2. 查看 Actions 标签页，等待自动编译完成"
    echo "  3. 在 Artifacts 中下载编译好的 IPK 包"
    echo ""
    echo "创建版本发布："
    echo "  git tag v1.0.0"
    echo "  git push origin v1.0.0"
    echo ""
    echo "详细说明请查看: GITHUB.md"
    echo "========================================"
else
    echo ""
    echo "========================================"
    echo "Git 仓库已配置"
    echo "========================================"
    echo ""
    echo "稍后手动推送："
    echo "  git push -u origin main"
    echo ""
    echo "或创建标签并推送："
    echo "  git tag v1.0.0"
    echo "  git push origin main"
    echo "  git push origin v1.0.0"
    echo "========================================"
fi

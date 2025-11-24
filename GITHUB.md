# GitHub 自动编译指南

本项目已配置 GitHub Actions，可以自动编译 OpenWRT 插件包。

## 🚀 自动编译功能

### 触发条件

自动编译会在以下情况触发：

1. **推送代码到主分支**：`git push origin main`
2. **创建标签**：`git tag v1.0.0 && git push origin v1.0.0`
3. **Pull Request**：创建或更新 PR
4. **手动触发**：在 GitHub Actions 页面手动运行

### 编译架构

GitHub Actions 会自动为以下架构编译 IPK 包：

| 架构 | 适用设备 |
|------|---------|
| x86_64 | x86 软路由、虚拟机 |
| aarch64_cortex-a53 | 树莓派 3/4、部分 ARM64 设备 |
| arm_cortex-a9 | 部分 ARM 路由器 |
| mipsel_24kc | 小米路由器、部分 MT7621 设备 |
| all (简化版) | 架构无关版本 |

## 📦 使用编译好的包

### 方法 1：从 Actions 下载

1. 访问项目的 **Actions** 标签页
2. 选择最新的成功构建
3. 在 **Artifacts** 部分下载对应架构的 IPK 包
4. 解压并安装到路由器

### 方法 2：从 Releases 下载（推荐）

当您创建版本标签时，编译好的包会自动上传到 Releases：

```bash
# 创建版本标签
git tag v1.0.0
git push origin v1.0.0
```

然后访问项目的 **Releases** 页面下载。

## 🔧 初次设置 GitHub 仓库

### 1. 创建 GitHub 仓库

```bash
# 在项目目录下
cd e:\dev\openwrt-ezwol

# 初始化 Git（如果还没有）
git init

# 添加所有文件
git add .

# 提交
git commit -m "Initial commit: EzWoL OpenWRT plugin"

# 添加远程仓库（替换为您的仓库地址）
git remote add origin https://github.com/yourusername/openwrt-ezwol.git

# 推送到 GitHub
git branch -M main
git push -u origin main
```

### 2. 查看自动编译状态

1. 推送代码后，访问 GitHub 仓库页面
2. 点击 **Actions** 标签
3. 查看编译进度和结果

### 3. 下载编译好的包

编译完成后：
- 点击具体的工作流运行
- 在 **Artifacts** 部分下载对应架构的包
- 或在 **Releases** 页面下载（如果是标签触发）

## 📝 发布新版本

### 创建版本发布

```bash
# 更新版本号（编辑 ezwol/Makefile）
# PKG_VERSION:=1.0.1

# 提交更改
git add ezwol/Makefile
git commit -m "Bump version to 1.0.1"

# 创建标签
git tag v1.0.1

# 推送代码和标签
git push origin main
git push origin v1.0.1
```

GitHub Actions 会自动：
1. 编译所有架构的 IPK 包
2. 创建 GitHub Release
3. 上传所有编译好的包到 Release

## 🛠️ 自定义编译

### 添加更多架构

编辑 `.github/workflows/build.yml`，在 `matrix.arch` 中添加：

```yaml
- name: 架构名称
  sdk_url: OpenWRT SDK 下载地址
```

SDK 下载地址可以从 [OpenWRT Downloads](https://downloads.openwrt.org/) 获取。

### 修改 OpenWRT 版本

将 workflow 文件中的 `23.05.3` 替换为其他版本号。

## 📊 编译状态徽章

在 README.md 中添加状态徽章：

```markdown
[![Build Status](https://github.com/yourusername/openwrt-ezwol/workflows/Build%20OpenWRT%20Package/badge.svg)](https://github.com/yourusername/openwrt-ezwol/actions)
```

## ⚠️ 注意事项

1. **首次编译时间较长**：下载 SDK 和编译可能需要 10-20 分钟
2. **GitHub Actions 限制**：免费账户每月有 2000 分钟的限制
3. **Artifacts 保留期**：默认保留 90 天
4. **Release 文件**：永久保存，推荐用于正式版本

## 🔍 故障排查

### 编译失败

1. 查看 Actions 日志找到错误信息
2. 检查 Makefile 语法
3. 确认依赖包名称正确（etherwake, socat）

### 无法下载 Artifacts

- 确保已登录 GitHub
- Artifacts 只对仓库成员可见
- 使用 Releases 分发给公众用户

## 📚 相关文档

- [GitHub Actions 文档](https://docs.github.com/en/actions)
- [OpenWRT SDK 使用](https://openwrt.org/docs/guide-developer/toolchain/using_the_sdk)
- [创建 GitHub Release](https://docs.github.com/en/repositories/releasing-projects-on-github)

# EzWoL 快速构建指南

## 方法一：使用 OpenWRT SDK（推荐）

### 1. 下载 OpenWRT SDK

访问 [OpenWRT Downloads](https://downloads.openwrt.org/) 下载对应您路由器架构的SDK。

例如，对于 x86_64 架构：
```bash
wget https://downloads.openwrt.org/releases/23.05.0/targets/x86/64/openwrt-sdk-23.05.0-x86-64_gcc-12.3.0_musl.Linux-x86_64.tar.xz
tar xf openwrt-sdk-*.tar.xz
cd openwrt-sdk-*/
```

### 2. 复制包到 SDK

```bash
# 复制 ezwol 目录到 SDK 的 package 目录
cp -r /path/to/openwrt-ezwol/ezwol package/

# 更新 feeds
./scripts/feeds update -a
./scripts/feeds install -a
```

### 3. 编译包

```bash
# 配置（可选，如果只编译这个包可以跳过）
make menuconfig
# 在 Network 分类中选择 ezwol

# 编译
make package/ezwol/compile V=s
```

### 4. 获取 IPK 文件

编译完成后，IPK 文件位于：
```
bin/packages/*/base/ezwol_1.0.0-1_all.ipk
```

---

## 方法二：手动打包（快速测试）

如果您只是想快速测试，可以手动创建 IPK 包：

### 1. 使用提供的打包脚本

```bash
cd openwrt-ezwol
chmod +x build-ipk.sh
./build-ipk.sh
```

这将在 `build/` 目录下生成 `ezwol_1.0.0-1_all.ipk`

### 2. 安装到路由器

```bash
scp build/ezwol_1.0.0-1_all.ipk root@192.168.1.1:/tmp/
ssh root@192.168.1.1
opkg install /tmp/ezwol_1.0.0-1_all.ipk
```

---

## 方法三：直接部署文件（开发测试）

如果您正在开发调试，可以直接复制文件到路由器：

```bash
# 使用提供的部署脚本
chmod +x deploy-dev.sh
./deploy-dev.sh root@192.168.1.1
```

这会直接将所有文件复制到路由器的正确位置。

---

## 常见架构对应

| 路由器品牌/型号 | 架构 |
|----------------|------|
| x86/64 软路由 | x86_64 |
| 树莓派 3/4 | aarch64_cortex-a53 |
| 小米路由器 3G | ramips/mt7621 |
| TP-Link WR841N | ar71xx/generic |
| Netgear R7800 | ipq806x |

查看您路由器的架构：
```bash
ssh root@192.168.1.1 "cat /etc/openwrt_release"
```

---

## 验证安装

安装后验证：
```bash
# 检查文件是否安装
opkg files ezwol

# 检查服务状态
/etc/init.d/ezwol status

# 查看配置
uci show ezwol
```

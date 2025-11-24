# GitHub Actions 故障排查指南

## 安装问题

### 缺少依赖包

**症状**：
```
cannot find dependency socat for ezwol
Cannot install package ezwol.
```

**原因**：
OpenWRT 路由器上没有安装 `socat` 和 `etherwake` 依赖包。

**解决方案**：

先安装依赖包，再安装 ezwol：

```bash
# 1. 更新包列表
opkg update

# 2. 安装依赖
opkg install socat etherwake

# 3. 安装 ezwol
opkg install ezwol_*.ipk
```

**一键安装脚本**：
```bash
opkg update && opkg install socat etherwake && opkg install /tmp/ezwol_*.ipk
```

### 架构不兼容

**症状**：
```
incompatible with the architectures configured
Cannot install package ezwol.
```

**原因**：
- 使用了错误架构的 IPK 包
- 或者使用快速构建的包但路由器不支持

**解决方案**：

#### 方案 A：使用快速构建的包（推荐）
快速构建生成的是 `all` 架构（架构无关），适用于大多数设备：
```bash
# 从 GitHub Actions 下载 ezwol-quick-build
opkg update
opkg install socat etherwake
opkg install ezwol_1.0.0-1_all.ipk
```

#### 方案 B：使用对应架构的包
如果快速构建的包不工作，使用完整 SDK 构建的对应架构包：

1. 查看路由器架构：
```bash
opkg print-architecture
```

2. 下载对应架构的 IPK 包（从 GitHub Releases）

3. 安装：
```bash
opkg update
opkg install socat etherwake
opkg install ezwol_*_<your-arch>.ipk
```

#### 方案 C：本地构建
```bash
# 在项目目录
./build-ipk.sh
# 生成的包在 build/ 目录
```

---

## LuCI 界面问题

### JavaScript 错误

**症状**：
```
TypeError: Cannot read properties of undefined (reading 'Checkbox')
```
或 LuCI 界面无法加载。

**原因**：
- LuCI 版本不兼容
- LuCI 缓存问题
- 文件权限问题

**解决方案**：

#### 方案 A：清除 LuCI 缓存
```bash
ssh root@192.168.1.1
rm -rf /tmp/luci-*
/etc/init.d/uhttpd restart
```

然后刷新浏览器（Ctrl+F5 强制刷新）。

#### 方案 B：检查文件权限
```bash
chmod 644 /usr/lib/lua/luci/controller/ezwol.lua
chmod 644 /usr/lib/lua/luci/model/cbi/ezwol.lua
chmod 644 /usr/lib/lua/luci/view/ezwol/usage.htm
```

#### 方案 C：重新安装
```bash
opkg remove ezwol
opkg install /tmp/ezwol_*.ipk
rm -rf /tmp/luci-*
/etc/init.d/uhttpd restart
```

#### 方案 D：使用命令行配置
如果 LuCI 界面始终有问题，可以完全通过命令行配置：
```bash
# 生成密钥
AUTH_KEY=$(head -c 32 /dev/urandom | base64 | tr -dc 'A-Za-z0-9' | head -c 32)

# 配置
uci set ezwol.config.enabled='1'
uci set ezwol.config.port='61323'
uci set ezwol.config.auth_key="$AUTH_KEY"
uci commit ezwol

# 启动
/etc/init.d/ezwol start
/etc/init.d/ezwol enable

# 显示密钥
echo "密钥: $AUTH_KEY"
```

### LuCI 菜单不显示

**症状**：
在 LuCI 界面的"服务"菜单中找不到 EzWoL 选项。

**解决方案**：

1. 清除缓存：
```bash
rm -rf /tmp/luci-*
/etc/init.d/uhttpd restart
```

2. 检查文件是否安装：
```bash
ls -l /usr/lib/lua/luci/controller/ezwol.lua
ls -l /usr/lib/lua/luci/model/cbi/ezwol.lua
```

3. 如果文件不存在，重新安装插件。

---

## 配置文件问题

### 配置文件冲突警告

**症状**：
```
resolve_conffiles: Existing conffile /etc/config/ezwol is different...
The new conffile will be placed at /etc/config/ezwol-opkg.
```

**原因**：
这是 OpenWRT 的正常行为。当你修改了配置文件（例如设置了密钥），然后重新安装或升级插件时，系统会：
1. **保留**你现有的配置文件（`/etc/config/ezwol`），确保你的设置不丢失。
2. 将插件自带的默认配置文件保存为 `/etc/config/ezwol-opkg`。

**解决方案**：
- **无需操作**：如果你想保留当前的配置（密钥、端口等），直接忽略此警告即可。
- **恢复默认**：如果你想使用新的默认配置，可以运行：
  ```bash
  mv /etc/config/ezwol-opkg /etc/config/ezwol
  ```

---

## GitHub Actions 构建问题

## 常见问题和解决方案

### 1. SDK 下载超时

**症状**：
```
Error: The operation was canceled.
```
在 "Download OpenWRT SDK" 步骤失败。

**原因**：
- SDK 文件较大（200-300MB）
- GitHub Actions 网络不稳定
- 下载速度慢导致超时

**解决方案**：

#### 方案 A：重新运行工作流（推荐）
1. 进入 GitHub Actions 页面
2. 点击失败的工作流
3. 点击右上角 "Re-run failed jobs" 或 "Re-run all jobs"
4. SDK 缓存会在第二次运行时生效，加快速度

#### 方案 B：只使用快速构建
快速构建不依赖 SDK 下载，非常稳定：
- 每次推送自动触发
- 1-2 分钟完成
- 生成通用 IPK 包（适用于大多数设备）

#### 方案 C：本地构建
使用本地脚本构建：
```bash
./build-ipk.sh
```

### 2. 构建超时

**症状**：
```
Error: The operation was canceled.
```
在 "Build package" 或其他步骤超时。

**原因**：
- GitHub Actions 免费版有时间限制
- 构建过程耗时较长

**解决方案**：

已优化的配置：
- ✅ 增加了各步骤的超时限制
- ✅ 使用多核编译 `-j$(nproc)`
- ✅ 清理磁盘空间
- ✅ 添加 `fail-fast: false`（一个架构失败不影响其他）

如果仍然超时，使用快速构建或本地构建。

### 3. 配置失败

**症状**：
```
Error: The operation was canceled.
```
在 "Configure build" 步骤失败。

**解决方案**：
- 重新运行工作流
- 检查 Makefile 语法
- 使用快速构建作为替代

### 4. Feeds 更新错误

**症状**：
```
/home/runner/.../bin/find: 'feeds/telephony': No such file or directory
Error: Process completed with exit code 1.
```

**原因**：
某些 OpenWRT SDK 版本不包含 telephony feed。

**解决方案**：
已修复！workflow 现在只更新必要的 feeds：
```yaml
./scripts/feeds update base packages luci routing || true
./scripts/feeds install -a -p base
./scripts/feeds install -a -p packages
./scripts/feeds install -a -p luci || true
```

如果仍有问题，重新运行工作流即可。

### 5. 磁盘空间不足

**症状**：
```
No space left on device
```

**解决方案**：
已在 workflow 中添加磁盘清理步骤：
```yaml
- name: Free disk space
  run: |
    sudo rm -rf /usr/share/dotnet
    sudo rm -rf /opt/ghc
```

## 推荐策略

### 对于大多数用户

**使用快速构建**：
- ✅ 稳定可靠
- ✅ 速度快（1-2 分钟）
- ✅ 不会超时
- ✅ 生成的包适用于大多数设备

```bash
# 正常推送即可
git push
```

### 对于正式发布

**使用完整 SDK 构建**：
- 创建版本标签触发
- 如果失败，重新运行
- 或者手动触发工作流

```bash
git tag v1.0.0
git push origin v1.0.0
```

如果多次失败，可以：
1. 使用快速构建的包发布
2. 或在本地使用 OpenWRT SDK 构建

### 对于开发者

**本地构建**：
```bash
# 快速构建（推荐）
./build-ipk.sh

# 或使用 OpenWRT SDK（需要 Linux）
# 参考 BUILD.md
```

## 工作流状态检查

### 查看构建状态

1. 访问 GitHub 仓库
2. 点击 **Actions** 标签
3. 查看工作流运行状态：
   - ✅ 绿色：成功
   - ❌ 红色：失败
   - 🟡 黄色：运行中
   - ⚪ 灰色：已取消

### 查看详细日志

1. 点击具体的工作流运行
2. 点击失败的任务
3. 展开失败的步骤
4. 查看错误信息

## 优化建议

### 1. 使用缓存

SDK 缓存会在第一次成功下载后保存，后续构建会快很多。

### 2. 选择合适的触发时机

- **快速构建**：每次推送
- **完整构建**：仅在发布时

### 3. 手动触发

如果自动触发失败，可以手动触发：
1. Actions → 选择工作流
2. Run workflow
3. 选择分支
4. Run

### 4. 分批构建

如果所有架构一起构建容易超时，可以：
1. 手动触发工作流
2. 每次只构建一个架构
3. 修改 workflow 文件，注释掉部分架构

## 联系支持

如果问题持续存在：
1. 检查 GitHub Actions 状态页面
2. 查看项目 Issues
3. 使用本地构建作为备选方案

## 总结

| 构建方式 | 稳定性 | 速度 | 推荐场景 |
|---------|--------|------|---------|
| 快速构建 | ⭐⭐⭐⭐⭐ | ⭐⭐⭐⭐⭐ | 日常开发、测试 |
| 完整 SDK 构建 | ⭐⭐⭐ | ⭐⭐ | 正式发布 |
| 本地构建 | ⭐⭐⭐⭐⭐ | ⭐⭐⭐⭐ | 开发调试 |

**推荐**：优先使用快速构建，正式发布时使用完整构建或本地构建。

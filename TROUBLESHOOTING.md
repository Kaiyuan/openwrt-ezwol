# GitHub Actions 故障排查指南

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

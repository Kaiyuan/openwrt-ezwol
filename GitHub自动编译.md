# GitHub 自动编译快速指南

## 🎯 一键上传到 GitHub 并自动编译

### Windows 用户

1. **双击运行** `init-git.bat`
2. 输入您的 GitHub 仓库地址（需要先在 GitHub 创建空仓库）
3. 等待推送完成
4. 访问 GitHub 仓库的 **Actions** 页面查看编译进度

### Linux/macOS/WSL 用户

```bash
chmod +x init-git.sh
./init-git.sh
```

## 📦 下载编译好的包

### 方法 1：从 Actions 下载（每次提交）

1. 访问 GitHub 仓库
2. 点击 **Actions** 标签
3. 选择最新的成功构建
4. 在页面底部 **Artifacts** 区域下载对应架构的包

### 方法 2：从 Releases 下载（正式版本）

创建版本标签后自动发布：

```bash
git tag v1.0.0
git push origin v1.0.0
```

然后访问仓库的 **Releases** 页面下载。

## 🏗️ 支持的架构

GitHub Actions 会自动编译以下架构：

| 架构 | 适用设备 | 文件名 |
|------|---------|--------|
| x86_64 | x86 软路由、虚拟机 | ezwol-x86_64 |
| aarch64_cortex-a53 | 树莓派 3/4 | ezwol-aarch64_cortex-a53 |
| arm_cortex-a9 | ARM 路由器 | ezwol-arm_cortex-a9 |
| mipsel_24kc | 小米路由器、MT7621 | ezwol-mipsel_24kc |
| all | 通用版本 | ezwol-all-simple |

## 📝 常见操作

### 更新代码并触发编译

```bash
# 修改代码后
git add .
git commit -m "修复某个问题"
git push
```

推送后会自动触发编译。

### 发布新版本

```bash
# 1. 更新版本号（编辑 ezwol/Makefile）
# PKG_VERSION:=1.0.1

# 2. 提交更改
git add ezwol/Makefile
git commit -m "发布版本 1.0.1"

# 3. 创建标签
git tag v1.0.1

# 4. 推送
git push origin main
git push origin v1.0.1
```

几分钟后，在 **Releases** 页面会自动出现新版本和所有架构的 IPK 包。

## ⏱️ 编译时间

- **首次编译**：约 15-20 分钟（需要下载 SDK）
- **后续编译**：约 5-10 分钟（使用缓存）

## 🔍 查看编译日志

1. 进入 **Actions** 页面
2. 点击具体的工作流运行
3. 点击对应的任务（如 "Build IPK Package (x86_64)"）
4. 展开步骤查看详细日志

## ❓ 常见问题

### 编译失败怎么办？

1. 查看 Actions 日志找到错误信息
2. 检查代码语法
3. 确认依赖包名称正确

### 如何添加更多架构？

编辑 `.github/workflows/build.yml`，在 `matrix.arch` 中添加新架构的 SDK 地址。

### 编译好的包在哪里？

- **临时下载**：Actions → 选择构建 → Artifacts
- **永久下载**：Releases 页面（需要创建标签）

## 🎉 完成！

现在您的项目已经配置好自动编译，每次推送代码都会自动生成所有架构的 IPK 包！

详细文档请查看：[GITHUB.md](GITHUB.md)

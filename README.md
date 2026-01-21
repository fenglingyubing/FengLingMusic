# 风铃音乐 (FengLing Music)

<div align="center">

**一款现代化的跨平台音乐播放器**

支持 Windows 和 Android 双平台 | 120fps 流畅动画 | 在线搜索播放 | 高清歌词显示

[![Flutter](https://img.shields.io/badge/Flutter-3.38.5-02569B?logo=flutter)](https://flutter.dev)
[![License](https://img.shields.io/badge/License-MIT-green.svg)](LICENSE)
[![Platform](https://img.shields.io/badge/Platform-Windows%20%7C%20Android-blue)](.)

</div>

---

## ✨ 主要特性

### 🎵 音乐管理
- 📁 自动扫描本地音乐库
- 🎨 按艺术家、专辑、文件夹分类浏览
- 🔍 快速搜索歌曲、艺术家、专辑
- ⭐ 收藏歌曲和播放历史记录
- 📋 创建和管理播放列表（支持 M3U 导入/导出）

### 🎧 播放控制
- ▶️ 支持多种音频格式（MP3, FLAC, WAV, AAC, OGG, M4A）
- 🔀 多种播放模式（顺序、随机、单曲循环、列表循环）
- 🎚️ 音量控制、进度调整
- 🎼 播放队列管理和拖拽排序

### 🌐 在线功能
- 🔍 多平台音乐搜索（网易云、QQ音乐、酷狗音乐）
- 🎶 在线音乐播放和缓存
- 📥 下载音乐（支持多音质、断点续传）
- 📝 在线歌词获取和显示

### 📜 歌词功能
- 🎤 实时滚动歌词显示
- 🌐 支持翻译歌词
- 💻 桌面歌词（Windows）
- 🔒 锁屏歌词（Android）

### ⚡ 高性能动画
- 🚀 支持 120/144/165Hz 高刷新率
- 🎬 流畅的过渡动画和微交互
- 📊 性能自适应和帧率监控

### 🖥️ 平台特性

#### Windows
- 🖱️ 系统托盘集成
- ⌨️ 全局快捷键（可自定义）
- 🪟 桌面歌词悬浮窗
- 📺 高刷新率显示器自动检测

#### Android
- 🔔 媒体通知栏控制
- 🎧 后台播放和前台服务
- 🔒 锁屏播放控制
- 🎯 桌面小部件（计划中）

### 🎨 界面设计
- 🌓 浅色/深色主题切换
- 🎨 自定义主题色
- 💫 Neo-Vinyl 设计美学
- 📱 响应式布局

---

## 📸 截图

_截图即将添加_

---

## 🚀 快速开始

### 系统要求

#### Windows
- Windows 10 (1809+) 或 Windows 11
- 4GB RAM（推荐 8GB）
- 200MB 可用空间

#### Android
- Android 8.0 (API 26) 或更高版本
- 2GB RAM（推荐 4GB）
- 100MB 可用空间

### 安装

#### 从 Releases 下载
1. 访问 [GitHub Releases](https://github.com/fenglingyubing/FengLingMusic/releases)
2. 下载适合你平台的安装包
   - Windows: `FengLingMusic-Setup-x64.exe`
   - Android: `app-release.apk` 或从 Google Play 安装

#### 从源码构建

```bash
# 克隆项目
git clone https://github.com/fenglingyubing/FengLingMusic.git
cd FengLingMusic/fenglingmusic

# 安装依赖
flutter pub get

# 运行代码生成（如需要）
flutter pub run build_runner build --delete-conflicting-outputs

# 运行应用
flutter run -d windows  # Windows
flutter run -d <device-id>  # Android
```

---

## 📖 文档

- [用户手册](docs/user-manual.md) - 如何使用风铃音乐
- [开发文档](docs/development.md) - 开发环境搭建和构建流程
- [API 文档](docs/api-documentation.md) - API 接口说明
- [设计文档](docs/design.md) - 架构设计和技术选型
- [需求文档](docs/requirements.md) - 功能需求和规格
- [任务清单](docs/tasks.md) - 开发任务和进度
- [Android 签名指南](docs/android-signing-guide.md) - Android 应用签名配置

---

## 🛠️ 技术栈

- **框架**: Flutter 3.38.5
- **语言**: Dart 3.10.4
- **状态管理**: Riverpod 2.4.0
- **音频播放**: just_audio, audio_service, media_kit
- **数据库**: SQLite, Hive
- **网络**: Dio
- **动画**: flutter_animate, animations
- **序列化**: freezed, json_serializable
- **Windows 平台**: system_tray, hotkey_manager, window_manager

---

## 📋 开发计划

### ✅ 已完成
- [x] 基础播放功能
- [x] 本地音乐库管理
- [x] 播放列表功能
- [x] 在线搜索和播放
- [x] 歌词显示
- [x] Windows 系统托盘和全局快捷键
- [x] 120fps 高刷新率支持
- [x] 单元测试框架

### 🚧 进行中
- [ ] 文档完善
- [ ] UI/UX 优化
- [ ] 性能优化

### 📅 计划中
- [ ] iOS 支持
- [ ] macOS 支持
- [ ] 均衡器
- [ ] 播客支持
- [ ] 智能推荐
- [ ] 云端同步

完整的任务清单请查看 [tasks.md](docs/tasks.md)。

---

## 🤝 贡献

我们欢迎任何形式的贡献！

### 如何贡献

1. Fork 本项目
2. 创建功能分支 (`git checkout -b feature/AmazingFeature`)
3. 提交更改 (`git commit -m 'feat: 添加某个很棒的功能'`)
4. 推送到分支 (`git push origin feature/AmazingFeature`)
5. 创建 Pull Request

### 提交规范

```
feat: 新功能
fix: 修复 bug
docs: 文档更新
style: 代码格式调整
refactor: 重构
perf: 性能优化
test: 测试相关
chore: 构建/工具链相关
```

详见 [开发文档](docs/development.md#贡献指南)。

---

## 🐛 问题反馈

遇到问题或有功能建议？

- [提交 Issue](https://github.com/fenglingyubing/FengLingMusic/issues/new)
- [参与讨论](https://github.com/fenglingyubing/FengLingMusic/discussions)

---

## 📄 许可证

本项目采用 [MIT License](LICENSE) 开源。

---

## 🙏 致谢

感谢所有为这个项目做出贡献的开发者！

### 使用的开源库

- [Flutter](https://flutter.dev) - 跨平台 UI 框架
- [just_audio](https://pub.dev/packages/just_audio) - 音频播放
- [Riverpod](https://riverpod.dev) - 状态管理
- [Dio](https://pub.dev/packages/dio) - 网络请求
- 以及其他优秀的开源项目

---

## 📞 联系方式

- **项目主页**: [GitHub](https://github.com/fenglingyubing/FengLingMusic)
- **Email**: support@fenglingmusic.com
- **社区讨论**: [GitHub Discussions](https://github.com/fenglingyubing/FengLingMusic/discussions)

---

<div align="center">

**如果这个项目对你有帮助，请给个 ⭐ Star 支持一下！**

Made with ❤️ by FengLing Music Team

</div>


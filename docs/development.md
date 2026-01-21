# FengLing Music - 开发流程文档

## 环境要求
- Flutter 3.38.5 或更高版本
- Dart 3.10.4 或更高版本
- Windows 10/11 (用于 Windows 构建)
- Visual Studio 2019 或 2022 (包含 C++ 桌面开发工具)

## 快速开始

### 1. 克隆项目
```bash
git clone <repository-url>
cd FengLingMusic/fenglingmusic
```

### 2. 安装依赖
```bash
flutter pub get
```

### 3. 生成代码（如果需要）
如果修改了使用 `@freezed`、`@riverpod` 或 JSON 序列化的代码，需要运行：
```bash
flutter pub run build_runner build --delete-conflicting-outputs
```

## 构建性能优化

### ⚡ 最快的开发方式：使用热重载（推荐）

**Windows 用户**（双击运行）：
```bash
dev_run.bat
```

**或者手动运行**：
```bash
flutter run -d windows --fast-start
```

**优势**：
- ✅ 支持热重载（按 `r` 键）和热重启（按 `R` 键）
- ✅ 无需等待完整重新编译
- ✅ 修改 UI 代码后即时预览
- ✅ 开发效率最高

**注意**：
- 修改 `@freezed`、`@riverpod` 注解的代码需要先运行 `build_runner`
- 添加新资源文件需要热重启（按 `R`）

### 🚀 快速构建脚本

**Windows 用户**（双击运行）：
```bash
build_windows_fast.bat
```

这个脚本会：
1. 运行增量代码生成
2. 获取依赖
3. 使用 Profile 模式构建（比 Release 快，性能良好）
4. 跳过图标树摇优化（加快构建）

### 构建模式对比

| 模式 | 构建速度 | 运行性能 | 调试功能 | 适用场景 |
|------|---------|---------|---------|---------|
| **热重载** | ⚡⚡⚡⚡⚡ 最快 | 良好 | ✅ 完整 | 日常开发（推荐） |
| **Debug** | ⚡⚡⚡ 较快 | 一般 | ✅ 完整 | 需要调试器时 |
| **Profile** | ⚡⚡ 中等 | ⚡⚡⚡ 很好 | ⚡ 部分 | 性能测试 |
| **Release** | ⚡ 慢 | ⚡⚡⚡⚡⚡ 最佳 | ❌ 无 | 发布版本 |

## 性能优化清单

### ✅ 已实施的优化

1. **CMake 编译优化**（`windows/CMakeLists.txt:40-46`）
   - ✅ 启用多处理器编译 (`/MP`)
   - ✅ 降低警告级别（`/W3` 而非 `/W4`）
   - ✅ 移除"警告视为错误"（开发时更快）

2. **Build Runner 优化**（`build.yaml:17-21`）
   - ✅ 启用构建缓存
   - ✅ 并发构建器数量 = 8

3. **构建脚本优化**
   - ✅ 增量代码生成（`--delete-conflicting-outputs`）
   - ✅ 跳过图标树摇（`--no-tree-shake-icons`）
   - ✅ 使用 Profile 模式构建

### 💡 开发最佳实践

1. **日常开发使用热重载**
   ```bash
   flutter run -d windows --fast-start
   ```
   - 修改代码后按 `r` 热重载
   - 添加新文件后按 `R` 热重启
   - 只在需要时才运行 `build_runner`

2. **仅在必要时运行代码生成**
   ```bash
   # 仅当修改了 @freezed、@riverpod 或 JSON 模型时运行
   flutter pub run build_runner build --delete-conflicting-outputs
   ```

3. **定期清理构建缓存**（如果遇到奇怪问题）
   ```bash
   flutter clean
   flutter pub get
   ```

4. **使用 Profile 模式进行性能测试**
   ```bash
   flutter run -d windows --profile
   ```

5. **仅在发布时使用 Release 模式**
   ```bash
   flutter build windows --release
   ```

## 构建时间对比

| 构建方式 | 首次构建 | 增量构建 | 热重载 |
|---------|---------|---------|-------|
| **优化前** | ~5-10 分钟 | ~3-5 分钟 | ~1-3 秒 |
| **优化后** | ~3-6 分钟 | ~1-2 分钟 | ~1-3 秒 |

## 常见问题

### Q: 为什么第一次构建还是很慢？
A: 首次构建需要编译所有 C++ 代码和 Flutter 引擎，这是正常的。后续的增量构建会快很多。

### Q: 热重载不工作怎么办？
A:
1. 确保使用 `flutter run` 而不是 `flutter build`
2. 某些代码修改（如 `@freezed`）需要运行 `build_runner` 后重启
3. 尝试按 `R` 热重启而不是 `r` 热重载

### Q: build_runner 很慢怎么办？
A:
1. 使用 `--delete-conflicting-outputs` 进行增量构建
2. 只在修改相关代码时运行
3. 考虑减少 `@freezed` 类的数量，合并相似的模型

### Q: 如何进一步提升构建速度？
A:
1. 使用 SSD 硬盘
2. 增加 RAM（推荐 16GB+）
3. 使用更快的 CPU（更多核心）
4. 关闭杀毒软件的实时扫描（针对项目目录）

## Git 工作流

### 分支管理
- `main`: 主分支，保护分支
- `vk/*`: 功能分支，开发完成后合并到 main

### 提交规范
```bash
# 功能
git commit -m "feat: 添加新功能"

# 修复
git commit -m "fix: 修复 bug"

# 优化
git commit -m "perf: 优化构建性能"

# 文档
git commit -m "docs: 更新开发文档"
```

### 合并到 main 的流程
1. Rebase 到最新 main
   ```bash
   git fetch origin
   git rebase origin/main
   ```

2. 解决冲突（如有）
   ```bash
   git add .
   git rebase --continue
   ```

3. 测试构建
   ```bash
   flutter pub get
   flutter test
   flutter build windows --profile
   ```

4. 推送并创建 PR
   ```bash
   git push -f origin <branch-name>
   gh pr create --title "描述" --body "详细说明"
   ```

## 项目结构
```
fenglingmusic/
├── lib/
│   ├── core/          # 核心功能
│   ├── features/      # 功能模块
│   ├── shared/        # 共享组件
│   └── main.dart      # 应用入口
├── windows/           # Windows 平台代码
├── test/              # 测试文件
├── build.yaml         # Build Runner 配置
├── pubspec.yaml       # 依赖配置
├── dev_run.bat        # 开发运行脚本（热重载）
└── build_windows_fast.bat  # 快速构建脚本
```

## 测试

### 运行单元测试
```bash
flutter test
```

### 运行特定测试
```bash
flutter test test/services/audio_player_service_test.dart
```

### 测试覆盖率
```bash
flutter test --coverage
genhtml coverage/lcov.info -o coverage/html
```

### 集成测试（Windows）
```bash
flutter test integration_test/app_test.dart -d windows
```

## 代码规范

### Dart 代码规范
- 使用 `flutter analyze` 检查代码
- 遵循 [Effective Dart](https://dart.dev/guides/language/effective-dart) 规范
- 使用 `dart format .` 格式化代码

### 命名规范
- 文件名：`snake_case.dart`
- 类名：`PascalCase`
- 变量和函数：`camelCase`
- 常量：`kPascalCase` 或 `SCREAMING_SNAKE_CASE`

### 注释规范
```dart
/// 这是一个公共 API 的文档注释
///
/// 详细说明功能...
///
/// Example:
/// ```dart
/// final player = AudioPlayerService();
/// await player.play(song);
/// ```
class AudioPlayerService {
  // 这是私有实现的注释
  void _internalMethod() {}
}
```

## 发布流程

### 1. 准备发布

#### 更新版本号
编辑 `pubspec.yaml`：
```yaml
version: 1.0.0+1  # version+build_number
```

#### 更新 Changelog
创建 `CHANGELOG.md` 记录版本变更。

#### 运行完整测试
```bash
flutter test
flutter analyze
flutter build windows --release
```

### 2. 构建发布包

#### Windows 发布包
```bash
# 构建 Release 版本
flutter build windows --release

# 生成的文件在：
# build/windows/x64/runner/Release/
```

创建安装包：
1. 使用 Inno Setup 或 NSIS 创建安装向导
2. 或者打包成便携版 ZIP

#### Android 发布包
```bash
# 构建 APK
flutter build apk --release --split-per-abi

# 构建 App Bundle（用于 Google Play）
flutter build appbundle --release
```

签名配置见 [Android 签名配置](#android-签名配置)。

### 3. 创建 GitHub Release

```bash
# 创建标签
git tag -a v1.0.0 -m "Release version 1.0.0"
git push origin v1.0.0

# 使用 GitHub CLI 创建 Release
gh release create v1.0.0 \
  --title "FengLing Music v1.0.0" \
  --notes "Release notes..." \
  build/windows/Release/*.exe \
  build/app/outputs/bundle/release/*.aab
```

### 4. 发布到应用商店（可选）

#### Google Play
1. 登录 [Google Play Console](https://play.google.com/console)
2. 创建新版本
3. 上传 AAB 文件
4. 填写版本说明
5. 提交审核

#### Microsoft Store
1. 登录 [Partner Center](https://partner.microsoft.com/dashboard)
2. 创建新提交
3. 上传 MSIX 包
4. 填写应用信息
5. 提交认证

## Android 签名配置

### 生成签名密钥
```bash
keytool -genkey -v -keystore ~/upload-keystore.jks \
  -keyalg RSA -keysize 2048 -validity 10000 \
  -alias upload
```

### 配置签名
创建 `android/key.properties`：
```properties
storePassword=<密码>
keyPassword=<密码>
keyAlias=upload
storeFile=<密钥文件路径>
```

在 `android/app/build.gradle` 中配置：
```gradle
def keystoreProperties = new Properties()
def keystorePropertiesFile = rootProject.file('key.properties')
if (keystorePropertiesFile.exists()) {
    keystoreProperties.load(new FileInputStream(keystorePropertiesFile))
}

android {
    ...
    signingConfigs {
        release {
            keyAlias keystoreProperties['keyAlias']
            keyPassword keystoreProperties['keyPassword']
            storeFile keystoreProperties['storeFile'] ? file(keystoreProperties['storeFile']) : null
            storePassword keystoreProperties['storePassword']
        }
    }
    buildTypes {
        release {
            signingConfig signingConfigs.release
        }
    }
}
```

## 持续集成/持续部署 (CI/CD)

### GitHub Actions

创建 `.github/workflows/build.yml`：
```yaml
name: Build and Test

on:
  push:
    branches: [ main ]
  pull_request:
    branches: [ main ]

jobs:
  test:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      - uses: subosito/flutter-action@v2
        with:
          flutter-version: '3.38.5'
      - run: flutter pub get
      - run: flutter analyze
      - run: flutter test

  build-windows:
    runs-on: windows-latest
    steps:
      - uses: actions/checkout@v3
      - uses: subosito/flutter-action@v2
        with:
          flutter-version: '3.38.5'
      - run: flutter config --enable-windows-desktop
      - run: flutter build windows --release

  build-android:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      - uses: actions/setup-java@v3
        with:
          distribution: 'zulu'
          java-version: '11'
      - uses: subosito/flutter-action@v2
        with:
          flutter-version: '3.38.5'
      - run: flutter build apk --release
```

## 性能分析

### 使用 Flutter DevTools
```bash
# 启动应用（Profile 模式）
flutter run -d windows --profile

# 在浏览器中打开 DevTools
flutter pub global activate devtools
flutter pub global run devtools
```

### 性能监控工具
- **CPU Profiler**: 分析 CPU 使用情况
- **Memory**: 监控内存使用和泄漏
- **Performance**: 分析渲染性能和帧率
- **Network**: 监控网络请求

### 性能优化检查清单
- [ ] 使用 `const` 构造函数
- [ ] 避免在 `build` 方法中创建对象
- [ ] 使用 `RepaintBoundary` 隔离动画
- [ ] 图片使用合适的尺寸和格式
- [ ] 列表使用 `ListView.builder`
- [ ] 避免不必要的状态重建

## 调试技巧

### 打印调试
```dart
import 'dart:developer' as developer;

// 使用 log 而不是 print
developer.log('Debug message', name: 'MyApp');

// 条件打印
if (kDebugMode) {
  print('Only in debug mode');
}
```

### 断点调试
1. 在 VS Code 中设置断点
2. 按 F5 启动调试
3. 使用 Debug Console 查看变量

### 常用调试技巧
```dart
// 显示 Widget 边界
import 'package:flutter/rendering.dart';
debugPaintSizeEnabled = true;

// 显示性能覆层
import 'package:flutter/material.dart';
MaterialApp(
  showPerformanceOverlay: true,
  ...
)
```

## 常见错误及解决方案

### 错误：DLL 找不到
```
Error: Unable to load DLL 'xyz.dll'
```
**解决方案**：确保所有依赖的 DLL 文件在可执行文件目录中。

### 错误：Riverpod 状态未初始化
```
StateError: Cannot read a provider while initializing a provider
```
**解决方案**：检查 Provider 依赖关系，避免循环依赖。

### 错误：build_runner 冲突
```
Conflicting outputs
```
**解决方案**：
```bash
flutter pub run build_runner build --delete-conflicting-outputs
```

### 错误：热重载失败
**解决方案**：按 `R` 进行热重启，或重新启动应用。

## 贡献指南

### 如何贡献

1. **Fork 项目**
   ```bash
   # 在 GitHub 上 Fork 项目
   git clone https://github.com/YOUR_USERNAME/FengLingMusic.git
   cd FengLingMusic
   ```

2. **创建功能分支**
   ```bash
   git checkout -b feature/my-new-feature
   ```

3. **提交更改**
   ```bash
   git add .
   git commit -m "feat: 添加新功能"
   ```

4. **推送到 GitHub**
   ```bash
   git push origin feature/my-new-feature
   ```

5. **创建 Pull Request**
   - 在 GitHub 上创建 PR
   - 描述清楚更改内容
   - 等待代码审查

### 代码审查检查清单

提交 PR 前请确保：
- [ ] 代码通过 `flutter analyze`
- [ ] 所有测试通过 `flutter test`
- [ ] 添加了必要的测试
- [ ] 更新了相关文档
- [ ] 遵循代码规范
- [ ] 提交信息清晰明确

### 报告 Bug

请在 GitHub Issues 中提交 Bug，包含：
1. 问题描述
2. 复现步骤
3. 预期行为
4. 实际行为
5. 环境信息（OS、Flutter 版本等）
6. 错误日志或截图

### 建议功能

在 GitHub Discussions 中提出功能建议，说明：
1. 功能描述
2. 使用场景
3. 预期收益
4. 可能的实现方案

## 许可证

本项目采用 MIT 许可证。详见 [LICENSE](../LICENSE) 文件。

## 资源链接
- [Flutter 官方文档](https://flutter.dev/docs)
- [Riverpod 文档](https://riverpod.dev)
- [Freezed 文档](https://pub.dev/packages/freezed)
- [项目设计文档](./design.md)
- [需求文档](./requirements.md)
- [任务清单](./tasks.md)
- [用户手册](./user-manual.md)
- [API 文档](./api-documentation.md)

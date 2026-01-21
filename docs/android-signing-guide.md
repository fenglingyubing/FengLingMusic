# Android 应用签名配置指南

## 重要说明

⚠️ **密钥安全**：密钥库文件和密码是敏感信息，务必妥善保管！
- 不要将密钥库文件提交到版本控制系统
- 不要在公开场合分享密钥密码
- 建议将密钥库文件备份到安全的地方

---

## 1. 生成签名密钥

### 方法一：使用 keytool（推荐）

打开终端，执行以下命令：

```bash
keytool -genkey -v -keystore ~/upload-keystore.jks \
  -keyalg RSA \
  -keysize 2048 \
  -validity 10000 \
  -alias upload
```

或者在 Windows 上：

```cmd
keytool -genkey -v -keystore %USERPROFILE%\upload-keystore.jks ^
  -keyalg RSA ^
  -keysize 2048 ^
  -validity 10000 ^
  -alias upload
```

### 填写密钥信息

执行命令后，会提示输入以下信息：

```
Enter keystore password: [输入密码]
Re-enter new password: [再次输入密码]
What is your first and last name?
  [Unknown]:  Feng Ling Music
What is the name of your organizational unit?
  [Unknown]:  Development
What is the name of your organization?
  [Unknown]:  FengLingMusic
What is the name of your City or Locality?
  [Unknown]:  Beijing
What is the name of your State or Province?
  [Unknown]:  Beijing
What is the two-letter country code for this unit?
  [Unknown]:  CN
Is CN=Feng Ling Music, OU=Development, O=FengLingMusic, L=Beijing, ST=Beijing, C=CN correct?
  [no]:  yes
```

### 参数说明

- `-keystore`: 密钥库文件路径
- `-keyalg RSA`: 使用 RSA 加密算法
- `-keysize 2048`: 密钥长度 2048 位
- `-validity 10000`: 有效期 10000 天（约 27 年）
- `-alias upload`: 密钥别名

---

## 2. 配置签名信息

### 创建密钥配置文件

在 `android/` 目录下创建 `key.properties` 文件：

```properties
storePassword=<你的密钥库密码>
keyPassword=<你的密钥密码>
keyAlias=upload
storeFile=<密钥库文件的绝对路径>
```

**示例**：
```properties
storePassword=MySecurePassword123
keyPassword=MySecurePassword123
keyAlias=upload
storeFile=/Users/yourname/upload-keystore.jks
```

**Windows 示例**：
```properties
storePassword=MySecurePassword123
keyPassword=MySecurePassword123
keyAlias=upload
storeFile=C:\\Users\\yourname\\upload-keystore.jks
```

### 添加到 .gitignore

确保 `key.properties` 文件不会被提交到 git：

在 `android/.gitignore` 中添加：
```
key.properties
*.jks
*.keystore
```

---

## 3. 验证配置

### 构建签名版本

```bash
cd fenglingmusic
flutter build apk --release
```

### 验证 APK 签名

```bash
# 安装 apksigner（Android SDK Build Tools）
# 验证签名
apksigner verify --verbose build/app/outputs/flutter-apk/app-release.apk
```

输出应该显示：
```
Verified using v1 scheme (JAR signing): true
Verified using v2 scheme (APK Signature Scheme v2): true
```

---

## 4. 构建不同版本

### 构建 APK（通用）

```bash
# 单个 APK（包含所有架构）
flutter build apk --release

# 分架构 APK（推荐，文件更小）
flutter build apk --release --split-per-abi
```

生成的文件：
- `app-armeabi-v7a-release.apk` (32位 ARM)
- `app-arm64-v8a-release.apk` (64位 ARM，主流)
- `app-x86_64-release.apk` (x86 64位)

### 构建 App Bundle（Google Play 推荐）

```bash
flutter build appbundle --release
```

生成的文件：
- `app-release.aab`

App Bundle 的优势：
- Google Play 会为不同设备生成优化的 APK
- 用户下载的文件更小
- 支持动态功能模块

---

## 5. 发布到 Google Play

### 准备材料

1. **签名的 AAB 文件**
   ```bash
   flutter build appbundle --release
   ```

2. **应用图标和截图**
   - 应用图标：512x512 PNG（已在 res/mipmap-* 中）
   - 截图：至少 2 张（手机、平板、电视等）
   - 宣传图：1024x500

3. **应用信息**
   - 应用名称
   - 简短描述（80 字符以内）
   - 完整描述（4000 字符以内）
   - 分类（音乐与音频）
   - 隐私政策 URL

### 上传步骤

1. 登录 [Google Play Console](https://play.google.com/console)
2. 创建新应用
3. 填写应用详情
4. 上传 AAB 文件
5. 填写内容分级
6. 设置定价和分发
7. 提交审核

---

## 6. 常见问题

### Q: 忘记密钥密码怎么办？
A: 密钥密码无法恢复。如果忘记，需要重新生成新的密钥。如果应用已发布到 Google Play，可以使用 Play App Signing。

### Q: 密钥库文件丢失怎么办？
A: 密钥库文件丢失意味着无法更新已发布的应用。务必备份！
Google Play App Signing 可以避免这个问题。

### Q: 如何使用 Play App Signing？
A:
1. 在 Google Play Console 中启用 Play App Signing
2. 上传你的签名密钥（仅一次）
3. 后续使用 upload key 签名上传
4. Google Play 会使用 app signing key 重新签名

### Q: Debug 和 Release 签名有什么区别？
A:
- **Debug**: 开发用，自动生成，不安全
- **Release**: 发布用，需要自己生成，安全可靠

### Q: 如何查看 APK 签名信息？
A:
```bash
keytool -printcert -jarfile app-release.apk
```

### Q: 签名配置报错怎么办？
A: 检查：
1. `key.properties` 文件路径是否正确
2. `storeFile` 路径是否使用绝对路径
3. Windows 路径是否使用双反斜杠 `\\`
4. 密码是否正确

---

## 7. 安全最佳实践

### 密钥管理

1. **备份密钥库**
   - 将 `.jks` 文件备份到安全的地方
   - 记录密码（使用密码管理器）

2. **使用环境变量**（CI/CD）
   ```bash
   # 在 CI/CD 中使用环境变量
   export KEYSTORE_PASSWORD=$KEYSTORE_PASSWORD
   export KEY_PASSWORD=$KEY_PASSWORD
   ```

3. **分离生产和测试密钥**
   - 测试环境使用测试密钥
   - 生产环境使用正式密钥

### Play App Signing（推荐）

使用 Google Play App Signing 的好处：
- Google 保管你的 app signing key
- 你只需保管 upload key
- upload key 丢失可以重新生成
- 更安全的密钥管理

---

## 8. 参考资料

- [Android 应用签名官方文档](https://developer.android.com/studio/publish/app-signing)
- [Flutter 发布 Android 应用](https://docs.flutter.dev/deployment/android)
- [Google Play App Signing](https://support.google.com/googleplay/android-developer/answer/9842756)
- [keytool 文档](https://docs.oracle.com/javase/8/docs/technotes/tools/unix/keytool.html)

---

## 附录：自动化脚本

### 生成密钥脚本（Linux/Mac）

创建 `scripts/generate-keystore.sh`:

```bash
#!/bin/bash

echo "=== FengLing Music - 生成签名密钥 ==="
echo ""

read -p "请输入密钥库密码: " -s STORE_PASSWORD
echo ""
read -p "请再次输入密钥库密码: " -s STORE_PASSWORD_CONFIRM
echo ""

if [ "$STORE_PASSWORD" != "$STORE_PASSWORD_CONFIRM" ]; then
    echo "密码不匹配！"
    exit 1
fi

KEYSTORE_PATH="$HOME/fenglingmusic-keystore.jks"

keytool -genkey -v -keystore "$KEYSTORE_PATH" \
    -keyalg RSA \
    -keysize 2048 \
    -validity 10000 \
    -alias upload \
    -dname "CN=Feng Ling Music, OU=Development, O=FengLingMusic, L=Beijing, ST=Beijing, C=CN" \
    -storepass "$STORE_PASSWORD" \
    -keypass "$STORE_PASSWORD"

echo ""
echo "✅ 密钥库已生成: $KEYSTORE_PATH"
echo ""
echo "请创建 android/key.properties 文件并添加以下内容："
echo ""
echo "storePassword=$STORE_PASSWORD"
echo "keyPassword=$STORE_PASSWORD"
echo "keyAlias=upload"
echo "storeFile=$KEYSTORE_PATH"
```

使用：
```bash
chmod +x scripts/generate-keystore.sh
./scripts/generate-keystore.sh
```

---

**注意**：本文档仅供开发参考，实际发布前请仔细阅读官方文档并做好密钥备份！

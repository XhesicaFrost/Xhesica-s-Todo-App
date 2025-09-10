# 📝 Xhesica's Todo App

一个功能丰富的Flutter待办事项应用，支持颜色分类、超时提醒和每日一言。

## ✨ 功能特点

### 🎯 核心功能
- **📋 待办事项管理** - 创建、编辑、删除待办事项
- **⏰ 时间管理** - 设置截止时间，自动识别超时项目
- **🎨 颜色分类** - 自由选择颜色标记不同类型的任务
- **💾 本地存储** - 数据本地保存，离线可用

### 🌟 特色功能
- **🚨 超时提醒** - 超时任务自动置顶并高亮显示
- **🌸 每日一言** - 集成一言API，每日励志语录
- **🎨 个性化** - 支持无色和自定义颜色选择
- **📱 响应式设计** - 适配不同屏幕尺寸

## 📸 应用截图

*即将添加...*

## 🛠️ 技术栈

- **Framework**: Flutter 3.16+
- **Language**: Dart
- **Storage**: 本地文件存储 (path_provider)
- **API**: 一言API (hitokoto.cn)
- **UI**: Material Design 3

## 📦 依赖项

```yaml
dependencies:
  flutter:
    sdk: flutter
  path_provider: ^2.0.11      # 本地存储
  http: ^1.1.0                # 网络请求
  flutter_colorpicker: ^1.0.3 # 颜色选择器
```

## 🚀 安装和运行

### 环境要求
- Flutter SDK 3.16.0+
- Dart SDK 3.1.5+
- Android SDK (用于Android构建)

### 安装步骤

1. **克隆仓库**
   ```bash
   git clone https://github.com/XhesicaFrost/Xhesica-s-Todo-App.git
   cd Xhesica-s-Todo-App
   ```

2. **安装依赖**
   ```bash
   flutter pub get
   ```

3. **运行应用**
   ```bash
   # 调试模式
   flutter run

   # 发布模式
   flutter run --release
   ```

4. **构建APK**
   ```bash
   flutter build apk --release
   ```

## 📁 项目结构

```
lib/
├── main.dart                 # 应用入口
├── models/
│   └── todo.dart            # Todo数据模型
├── pages/
│   ├── home_page.dart       # 主页面
│   ├── add_todo_page.dart   # 添加页面
│   └── edit_todo_page.dart  # 编辑页面
└── services/
    ├── storage_helper.dart  # 本地存储服务
    └── hitokoto_service.dart # 一言API服务
```

## 🎮 使用说明

### 基本操作
1. **添加待办事项** - 点击浮动按钮 ➕
2. **编辑待办事项** - 点击列表中的任意项目
3. **删除待办事项** - 在列表中点击删除按钮或在编辑页面删除
4. **刷新一言** - 点击标题栏右侧的刷新按钮 🔄

### 颜色功能
- **选择颜色** - 在添加/编辑页面选择自定义颜色
- **无色选项** - 支持不设置颜色，使用默认样式
- **颜色标识** - 每个待办事项用左侧边框和圆点显示颜色

### 超时管理
- **自动识别** - 系统自动识别超时的未完成任务
- **置顶显示** - 超时任务自动排序到列表顶部
- **视觉提醒** - 红色背景、边框和"超时"标签

## 🔄 自动构建

本项目配置了GitHub Actions，支持：

- **自动构建** - 推送代码到main分支自动构建APK
- **手动触发** - 可以手动设置版本号并构建
- **自动发布** - 自动创建GitHub Release并上传APK文件

### 手动触发构建
1. 进入GitHub仓库的Actions页面
2. 选择 "Build and Release APK" 工作流
3. 点击 "Run workflow"
4. 填写版本号和发布说明
5. 等待构建完成并下载APK

## 📈 版本历史

### v1.0.0 (2025-9-11)
- 🎉 首次发布
- ✅ 基础待办事项功能
- 🎨 颜色分类系统
- ⏰ 超时提醒功能
- 🌸 每日一言集成

## 🤝 贡献指南

欢迎提交Issue和Pull Request！

1. Fork本仓库
2. 创建功能分支 (`git checkout -b feature/AmazingFeature`)
3. 提交更改 (`git commit -m 'Add some AmazingFeature'`)
4. 推送分支 (`git push origin feature/AmazingFeature`)
5. 创建Pull Request

## 📄 许可证

本项目采用 MIT 许可证 - 查看 [LICENSE](LICENSE) 文件了解详情

## 👩‍💻 作者

**Xhesica Frost**
- GitHub: [@XhesicaFrost](https://github.com/XhesicaFrost)

## 🙏 致谢

- [一言API](https://hitokoto.cn/) - 提供每日励志语录
- [Flutter团队](https://flutter.dev/) - 优秀的跨平台框架
- [Material Design](https://material.io/) - 设计系统指导

---

⭐ 如果这个项目对您有帮助，请给它一个星标！
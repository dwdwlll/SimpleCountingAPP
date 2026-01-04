# SimpleCountingAPP
一个简单的用于计数的APP

## 功能特性

- ✅ 创建自定义命名的计数项目
- ✅ 删除单个项目
- ✅ 多选删除项目
- ✅ 计数显示（最大4位数：0000-9999）
- ✅ 加减按钮操作
- ✅ 自动保存计数结果到本地
- ✅ 支持 iOS 和 iPadOS

## 项目结构

```
SimpleCountingAPP/
├── SimpleCountingAPP/
│   ├── SimpleCountingAPPApp.swift      # 应用入口
│   ├── Models/
│   │   └── CountItem.swift             # 计数项数据模型
│   ├── ViewModels/
│   │   └── CountItemStore.swift        # 数据存储和管理
│   ├── Views/
│   │   ├── ContentView.swift           # 主列表界面
│   │   └── CountingView.swift          # 计数详情界面
│   ├── Assets.xcassets/                # 资源文件
│   └── Info.plist                      # 应用配置
└── SimpleCountingAPP.xcodeproj/        # Xcode项目文件
```

## 技术实现

- **框架**: SwiftUI
- **数据持久化**: UserDefaults (JSON编码)
- **架构**: MVVM
- **最低支持版本**: iOS 15.0

## 如何运行

1. 使用 Xcode 打开 `SimpleCountingAPP.xcodeproj`
2. 选择目标设备（iPhone 或 iPad 模拟器）
3. 点击运行按钮 (⌘+R)

## 使用说明

### 主界面
- 点击右上角 **+** 按钮创建新的计数项目
- 点击项目名称进入计数界面
- 点击 **选择** 按钮进入多选模式
- 在多选模式下，选择要删除的项目，然后点击 **删除选中**
- 左滑单个项目可以快速删除

### 计数界面
- 点击 **+** 按钮增加计数（最大9999）
- 点击 **-** 按钮减少计数（最小0）
- 点击 **重置** 按钮将计数归零
- 所有操作自动保存

## 开发者

dwdwlll

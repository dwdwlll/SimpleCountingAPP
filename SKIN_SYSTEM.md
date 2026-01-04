# 皮肤系统文档

## 概述

SimpleCountingAPP 的皮肤系统允许用户自定义计数器的外观，包括颜色、字体和视觉风格。用户可以通过皮肤商城购买和应用不同的主题。

## 架构

### 数据模型

#### CounterSkin
定义了单个皮肤的所有属性：
- **基本信息**: id, name, description, price, category
- **颜色配置**: 背景色、主色、次色、按钮颜色（增加/减少/重置）、文本色
- **视觉风格**: 字体样式、按钮样式
- **购买状态**: isPurchased, isDefault

#### SkinCategory
皮肤分类枚举：
- 基础 (basic)
- 渐变 (gradient)
- 极简 (minimal)
- 暗黑 (dark)
- 炫彩 (colorful)
- 自然 (nature)
- 科技 (tech)

### ViewModels

#### SkinStore
管理所有皮肤的状态和持久化：
- **状态管理**: 已购买的皮肤列表、当前选中的皮肤
- **持久化**: 使用 UserDefaults 保存选择和购买记录
- **核心方法**:
  - `selectSkin(_:)` - 选择并应用皮肤
  - `purchaseSkin(_:)` - 标记皮肤为已购买
  - `isSkinPurchased(_:)` - 检查购买状态

### 服务层

#### PaymentService 协议
定义支付服务提供商的接口：
```swift
protocol PaymentService {
    var providerName: String { get }
    var isConfigured: Bool { get }
    
    func configure(with configuration: [String: Any])
    func processPurchase(itemId: String, amount: Double, currency: String, completion: @escaping (PaymentResult) -> Void)
    func restorePurchases(completion: @escaping ([String]) -> Void)
}
```

#### PaymentManager
管理多个支付提供商的单例：
- 注册和管理支付服务提供商
- 统一的支付接口
- 支持多种支付平台（当前实现 Stripe，可扩展）

#### StripePaymentService
Stripe 支付服务的实现：
- 当前为模拟实现（用于演示）
- 提供了完整的集成文档和注释
- 生产环境需要集成 Stripe iOS SDK

## 界面组件

### SkinShopView
皮肤商城主界面：
- **分类过滤**: 水平滚动的分类标签
- **网格布局**: 2列网格展示皮肤卡片
- **皮肤卡片**: 预览、名称、描述、价格、购买状态
- **购买流程**: 点击未购买的皮肤打开购买表单

### CategoryChip
分类筛选标签：
- 选中/未选中状态
- 圆角胶囊设计

### SkinCard
皮肤预览卡片：
- 皮肤颜色预览（背景色、文字色、按钮色）
- 选中状态标识
- 价格或"已拥有"标签

### PurchaseSheet
购买确认界面：
- 大尺寸皮肤预览
- 详细信息展示
- 支付按钮（显示处理中状态）
- 支付方式说明

## 使用流程

### 1. 浏览皮肤商城
```
主界面 -> 点击画笔图标 -> 进入皮肤商城
```

### 2. 筛选和预览
- 点击分类标签筛选特定类型的皮肤
- 查看皮肤卡片的预览效果
- 阅读皮肤描述和价格

### 3. 购买皮肤
```
点击未购买的皮肤 -> 打开购买表单 -> 确认信息 -> 点击"购买皮肤" -> 等待支付完成
```

### 4. 应用皮肤
- 购买成功后自动应用
- 或点击已购买的皮肤进行切换
- 返回计数界面查看效果

## 预设皮肤

### 1. 默认 (免费)
- 经典白色背景
- 绿色增加、红色减少、橙色重置
- 适合日常使用

### 2. 暗夜模式 ($0.99)
- 深色背景，护眼设计
- 适合夜间使用

### 3. 海洋 ($1.99)
- 清新的蓝绿色调
- 海洋渐变主题

### 4. 日落 ($1.99)
- 温暖的橙红色调
- 日落渐变主题

### 5. 极简 ($0.99)
- 单色简约设计
- 线框按钮风格

### 6. 霓虹 ($2.99)
- 炫彩霓虹灯效果
- 黑色背景配荧光色

### 7. 森林 ($1.99)
- 自然绿色主题
- 清新护眼

### 8. 科技蓝 ($2.99)
- 现代科技感
- 等宽字体

## 支付集成

### 当前实现
- 模拟 Stripe 支付（演示用）
- 2秒延迟模拟网络请求
- 自动生成交易ID

### 生产环境集成步骤

#### 1. 添加 Stripe SDK
```swift
// Package.swift 或 SPM
.package(url: "https://github.com/stripe/stripe-ios", from: "23.0.0")
```

#### 2. 配置 Stripe
```swift
// 在 AppDelegate 或 App 初始化时
import StripePaymentSheet

Stripe.configure {
    publishableKey = "pk_live_your_publishable_key"
}
```

#### 3. 后端集成
- 创建支付意图 API 端点
- 处理 Webhook 确认支付
- 返回客户端密钥

#### 4. 更新 StripePaymentService
参考文件中的详细注释实现真实的支付流程

### 扩展其他支付平台

实现 `PaymentService` 协议即可：

```swift
class ApplePayService: PaymentService {
    var providerName: String = "Apple Pay"
    var isConfigured: Bool = false
    
    func configure(with configuration: [String: Any]) {
        // 配置 Apple Pay
    }
    
    func processPurchase(itemId: String, amount: Double, currency: String, completion: @escaping (PaymentResult) -> Void) {
        // 实现 Apple Pay 支付流程
    }
    
    func restorePurchases(completion: @escaping ([String]) -> Void) {
        // 实现恢复购买
    }
}

// 在 PaymentManager 中注册
PaymentManager.shared.registerProvider(ApplePayService())
```

## 数据持久化

### 存储内容
1. **已购买的皮肤ID列表**: `Set<String>`
2. **当前选中的皮肤ID**: `String`
3. **皮肤列表** (可选): `[CounterSkin]`

### 存储位置
UserDefaults，键名：
- `purchasedSkinIds` - 购买记录
- `selectedSkinId` - 当前选中
- `counterSkins` - 皮肤列表（可选）

### 数据同步
- 每次购买后立即保存
- 每次选择皮肤后立即保存
- 应用启动时自动加载

## 颜色系统

### 颜色定义
使用十六进制字符串：
```swift
backgroundColor: "#FFFFFF"  // 白色
primaryColor: "#000000"     // 黑色
incrementColor: "#34C759"   // 绿色
```

### 颜色转换
`CounterSkin.color(from:)` 方法将十六进制字符串转换为 SwiftUI Color：
- 支持 3位 RGB (#RGB)
- 支持 6位 RGB (#RRGGBB)
- 支持 8位 ARGB (#AARRGGBB)

## 字体系统

### FontStyle 枚举
```swift
enum FontStyle: String, Codable {
    case rounded    // 圆角字体
    case serif      // 衬线字体
    case monospaced // 等宽字体
    case standard   // 标准字体
}
```

### 应用字体
```swift
private func fontForStyle(_ style: FontStyle, size: CGFloat) -> Font {
    switch style {
    case .rounded:
        return .system(size: size, weight: .bold, design: .rounded)
    // ...
    }
}
```

## 按钮样式

### ButtonStyleType 枚举
```swift
enum ButtonStyleType: String, Codable {
    case filled   // 填充样式
    case outlined // 线框样式
    case minimal  // 极简样式
}
```

当前实现使用 SF Symbols 图标，未来可扩展自定义按钮渲染。

## 测试建议

### 功能测试
1. 浏览皮肤商城
2. 筛选不同分类
3. 预览皮肤效果
4. 模拟购买流程
5. 切换应用皮肤
6. 重启应用验证持久化

### UI 测试
1. 不同设备尺寸适配
2. 横竖屏切换
3. 暗色模式兼容
4. 动画流畅性

## 未来扩展

### 功能扩展
- [ ] 用户自定义皮肤编辑器
- [ ] 皮肤分享和导入
- [ ] 限时免费皮肤
- [ ] 皮肤包订阅
- [ ] 动画皮肤效果

### 技术扩展
- [ ] iCloud 同步购买记录
- [ ] 服务器端皮肤配置
- [ ] 更多支付方式（Apple Pay, PayPal, 微信支付）
- [ ] A/B 测试不同皮肤
- [ ] 使用分析和推荐

## API 参考

### SkinStore
```swift
class SkinStore: ObservableObject {
    @Published var skins: [CounterSkin]
    @Published var selectedSkinId: String
    @Published var purchasedSkinIds: Set<String>
    
    var selectedSkin: CounterSkin { get }
    
    func selectSkin(_ skin: CounterSkin)
    func purchaseSkin(_ skinId: String)
    func isSkinPurchased(_ skinId: String) -> Bool
}
```

### PaymentManager
```swift
class PaymentManager: ObservableObject {
    static let shared: PaymentManager
    
    func registerProvider(_ provider: PaymentService)
    func setCurrentProvider(name: String)
    func purchase(itemId: String, amount: Double, currency: String, completion: @escaping (PaymentResult) -> Void)
    func restorePurchases(completion: @escaping ([String]) -> Void)
}
```

## 常见问题

### Q: 如何添加新皮肤？
A: 在 `CounterSkin.swift` 的 `extension CounterSkin` 中添加新的静态属性，然后更新 `allSkins` 数组。

### Q: 支付失败怎么办？
A: 当前为模拟实现，生产环境需要实现错误处理和重试机制。

### Q: 如何恢复购买？
A: 实现 `restorePurchases` 方法，查询后端验证用户的购买记录。

### Q: 能否离线使用已购买的皮肤？
A: 可以，购买记录保存在本地 UserDefaults，离线也可使用。

### Q: 如何更改价格？
A: 修改 `CounterSkin` 初始化时的 `price` 参数即可。

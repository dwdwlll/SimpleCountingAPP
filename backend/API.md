# API 文档

SimpleCountingAPP 后端 API 完整文档。

## 基础信息

- **Base URL**: `http://localhost:5000`
- **认证方式**: JWT Bearer Token
- **Content-Type**: `application/json`

## 认证

所有需要认证的接口都需要在请求头中携带 JWT 令牌：

```
Authorization: Bearer <your_jwt_token>
```

---

## 认证接口

### 1. 用户注册

**POST** `/api/auth/register`

创建新用户账户。

**请求体**:
```json
{
  "username": "johndoe",
  "email": "john@example.com",
  "password": "securepass123"
}
```

**响应** (201 Created):
```json
{
  "token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
  "user": {
    "id": "507f1f77bcf86cd799439011",
    "username": "johndoe",
    "email": "john@example.com",
    "avatar_url": null,
    "created_at": "2024-01-04T12:00:00",
    "updated_at": "2024-01-04T12:00:00"
  }
}
```

**错误响应** (400 Bad Request):
```json
{
  "error": "用户名已被使用"
}
```

---

### 2. 用户登录

**POST** `/api/auth/login`

用户登录获取 JWT 令牌。

**请求体**:
```json
{
  "email": "john@example.com",
  "password": "securepass123"
}
```

**响应** (200 OK):
```json
{
  "token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
  "user": {
    "id": "507f1f77bcf86cd799439011",
    "username": "johndoe",
    "email": "john@example.com",
    "avatar_url": null,
    "created_at": "2024-01-04T12:00:00",
    "updated_at": "2024-01-04T12:00:00"
  }
}
```

**错误响应** (401 Unauthorized):
```json
{
  "error": "邮箱或密码错误"
}
```

---

## 用户信息接口

### 3. 获取当前用户信息

**GET** `/api/users/me`

🔒 **需要认证**

获取当前登录用户的信息。

**响应** (200 OK):
```json
{
  "id": "507f1f77bcf86cd799439011",
  "username": "johndoe",
  "email": "john@example.com",
  "avatar_url": "https://example.com/avatar.jpg",
  "created_at": "2024-01-04T12:00:00",
  "updated_at": "2024-01-04T12:00:00"
}
```

---

### 4. 更新当前用户信息

**PUT** `/api/users/me`

🔒 **需要认证**

更新当前用户的个人信息。

**请求体**:
```json
{
  "username": "newusername",
  "avatar_url": "https://example.com/new-avatar.jpg"
}
```

**响应** (200 OK):
```json
{
  "id": "507f1f77bcf86cd799439011",
  "username": "newusername",
  "email": "john@example.com",
  "avatar_url": "https://example.com/new-avatar.jpg",
  "created_at": "2024-01-04T12:00:00",
  "updated_at": "2024-01-04T13:00:00"
}
```

---

## 计数项接口

### 5. 获取所有计数项

**GET** `/api/count-items`

🔒 **需要认证**

获取当前用户的所有计数项。

**响应** (200 OK):
```json
[
  {
    "id": "507f1f77bcf86cd799439012",
    "user_id": "507f1f77bcf86cd799439011",
    "name": "俯卧撑",
    "count": 50,
    "created_at": "2024-01-04T12:00:00",
    "updated_at": "2024-01-04T14:00:00"
  },
  {
    "id": "507f1f77bcf86cd799439013",
    "user_id": "507f1f77bcf86cd799439011",
    "name": "喝水次数",
    "count": 8,
    "created_at": "2024-01-04T12:00:00",
    "updated_at": "2024-01-04T14:00:00"
  }
]
```

---

### 6. 创建计数项

**POST** `/api/count-items`

🔒 **需要认证**

创建新的计数项。

**请求体**:
```json
{
  "name": "俯卧撑",
  "count": 0
}
```

**响应** (201 Created):
```json
{
  "id": "507f1f77bcf86cd799439012",
  "user_id": "507f1f77bcf86cd799439011",
  "name": "俯卧撑",
  "count": 0,
  "created_at": "2024-01-04T12:00:00",
  "updated_at": "2024-01-04T12:00:00"
}
```

---

### 7. 获取单个计数项

**GET** `/api/count-items/<item_id>`

🔒 **需要认证**

获取指定ID的计数项详情。

**响应** (200 OK):
```json
{
  "id": "507f1f77bcf86cd799439012",
  "user_id": "507f1f77bcf86cd799439011",
  "name": "俯卧撑",
  "count": 50,
  "created_at": "2024-01-04T12:00:00",
  "updated_at": "2024-01-04T14:00:00"
}
```

---

### 8. 更新计数项

**PUT** `/api/count-items/<item_id>`

🔒 **需要认证**

更新指定的计数项。

**请求体**:
```json
{
  "count": 100
}
```

**响应** (200 OK):
```json
{
  "id": "507f1f77bcf86cd799439012",
  "user_id": "507f1f77bcf86cd799439011",
  "name": "俯卧撑",
  "count": 100,
  "created_at": "2024-01-04T12:00:00",
  "updated_at": "2024-01-04T15:00:00"
}
```

---

### 9. 删除计数项

**DELETE** `/api/count-items/<item_id>`

🔒 **需要认证**

删除指定的计数项。

**响应** (200 OK):
```json
{
  "message": "删除成功"
}
```

---

### 10. 同步计数项

**POST** `/api/count-items/sync`

🔒 **需要认证**

批量同步计数项数据（用于跨平台数据同步）。如果计数项已存在则更新，不存在则创建。

**请求体**:
```json
{
  "items": [
    {"name": "俯卧撑", "count": 50},
    {"name": "喝水次数", "count": 8},
    {"name": "深蹲", "count": 30}
  ]
}
```

**响应** (200 OK):
```json
{
  "items": [
    {
      "id": "507f1f77bcf86cd799439012",
      "user_id": "507f1f77bcf86cd799439011",
      "name": "俯卧撑",
      "count": 50,
      "created_at": "2024-01-04T12:00:00",
      "updated_at": "2024-01-04T16:00:00"
    },
    {
      "id": "507f1f77bcf86cd799439013",
      "user_id": "507f1f77bcf86cd799439011",
      "name": "喝水次数",
      "count": 8,
      "created_at": "2024-01-04T12:00:00",
      "updated_at": "2024-01-04T16:00:00"
    },
    {
      "id": "507f1f77bcf86cd799439014",
      "user_id": "507f1f77bcf86cd799439011",
      "name": "深蹲",
      "count": 30,
      "created_at": "2024-01-04T16:00:00",
      "updated_at": "2024-01-04T16:00:00"
    }
  ]
}
```

---

## 支付接口

### 11. 创建支付意图

**POST** `/api/payments/create-intent`

🔒 **需要认证**

创建 Stripe 支付意图。

**请求体**:
```json
{
  "item_id": "skin_ocean",
  "amount": 199,
  "currency": "usd"
}
```

注：`amount` 单位为分（cents），199 表示 $1.99

**响应** (200 OK):
```json
{
  "client_secret": "pi_3xxxxx_secret_xxxxx",
  "payment_intent_id": "pi_3xxxxx"
}
```

---

### 12. 确认支付

**POST** `/api/payments/confirm`

🔒 **需要认证**

确认支付状态。

**请求体**:
```json
{
  "payment_intent_id": "pi_3xxxxx"
}
```

**响应** (200 OK):
```json
{
  "status": "succeeded",
  "payment_intent_id": "pi_3xxxxx"
}
```

---

### 13. Stripe Webhook

**POST** `/api/payments/webhook`

接收 Stripe 的 Webhook 回调。

**请求头**:
```
Stripe-Signature: t=xxx,v1=xxx
```

**请求体**: Stripe 事件 JSON

**响应** (200 OK):
```json
{
  "message": "支付成功处理"
}
```

---

### 14. 获取购买记录

**GET** `/api/payments/purchases`

🔒 **需要认证**

获取当前用户的所有购买记录。

**响应** (200 OK):
```json
{
  "purchases": [
    {
      "id": "507f1f77bcf86cd799439015",
      "user_id": "507f1f77bcf86cd799439011",
      "item_id": "skin_ocean",
      "amount": 199,
      "currency": "usd",
      "payment_intent_id": "pi_3xxxxx",
      "status": "succeeded",
      "created_at": "2024-01-04T12:00:00"
    }
  ]
}
```

---

## 通用接口

### 健康检查

**GET** `/health`

检查服务是否正常运行。

**响应** (200 OK):
```json
{
  "status": "ok",
  "message": "SimpleCountingAPP Backend is running"
}
```

---

### API 信息

**GET** `/`

获取 API 基本信息和端点列表。

**响应** (200 OK):
```json
{
  "name": "SimpleCountingAPP Backend API",
  "version": "1.0.0",
  "endpoints": {
    "auth": "/api/auth",
    "users": "/api/users",
    "count_items": "/api/count-items",
    "payments": "/api/payments",
    "health": "/health"
  }
}
```

---

## 错误代码

| 状态码 | 说明 |
|--------|------|
| 200 | 成功 |
| 201 | 创建成功 |
| 400 | 请求参数错误 |
| 401 | 未认证或认证失败 |
| 404 | 资源不存在 |
| 500 | 服务器内部错误 |

---

## 数据验证规则

### 用户名
- 长度：3-20个字符
- 允许：字母、数字、下划线、中文

### 密码
- 最小长度：8个字符

### 邮箱
- 必须是有效的邮箱格式

### 计数项名称
- 长度：1-50个字符

### 计数值
- 类型：整数
- 范围：0-9999

---

## 示例代码

### Python 请求示例

```python
import requests

# 注册用户
response = requests.post('http://localhost:5000/api/auth/register', json={
    'username': 'johndoe',
    'email': 'john@example.com',
    'password': 'securepass123'
})
data = response.json()
token = data['token']

# 创建计数项
headers = {'Authorization': f'Bearer {token}'}
response = requests.post(
    'http://localhost:5000/api/count-items',
    headers=headers,
    json={'name': '俯卧撑', 'count': 0}
)
print(response.json())
```

### Swift 请求示例

```swift
// 登录
let url = URL(string: "http://localhost:5000/api/auth/login")!
var request = URLRequest(url: url)
request.httpMethod = "POST"
request.setValue("application/json", forHTTPHeaderField: "Content-Type")

let body: [String: Any] = [
    "email": "john@example.com",
    "password": "securepass123"
]
request.httpBody = try? JSONSerialization.data(withJSONObject: body)

let task = URLSession.shared.dataTask(with: request) { data, response, error in
    if let data = data {
        let json = try? JSONSerialization.jsonObject(with: data)
        print(json)
    }
}
task.resume()
```

---

## 注意事项

1. 所有时间格式为 ISO 8601 标准
2. 金额单位为分（cents）
3. JWT 令牌有效期为 30 天
4. 生产环境请使用 HTTPS
5. Webhook 签名验证必须在生产环境启用

# SimpleCountingAPP Backend

Python后端服务，为SimpleCountingAPP提供用户认证、数据同步和支付服务。

## 功能特性

- ✅ 用户认证系统（注册、登录、JWT令牌）
- ✅ 用户信息管理（用户名、邮箱、头像等）
- ✅ 计数数据云存储（支持跨平台同步）
- ✅ Stripe支付集成
- ✅ MongoDB数据存储
- ✅ RESTful API设计

## 技术栈

- **框架**: Flask (Python 3.8+)
- **数据库**: MongoDB
- **认证**: JWT (JSON Web Tokens)
- **支付**: Stripe API
- **密码加密**: bcrypt
- **API文档**: 自动生成的OpenAPI规范

## 项目结构

```
backend/
├── app.py                  # Flask应用入口
├── config.py               # 配置文件
├── requirements.txt        # Python依赖
├── models/
│   ├── user.py            # 用户模型
│   └── count_item.py      # 计数项模型
├── routes/
│   ├── auth.py            # 认证路由
│   ├── users.py           # 用户信息路由
│   ├── count_items.py     # 计数数据路由
│   └── payments.py        # 支付路由
├── services/
│   ├── auth_service.py    # 认证服务
│   ├── payment_service.py # 支付服务
│   └── storage_service.py # 数据存储服务
└── utils/
    ├── jwt_utils.py       # JWT工具
    └── validators.py      # 数据验证工具
```

## 快速开始

### 1. 安装依赖

```bash
cd backend
pip install -r requirements.txt
```

### 2. 配置环境变量

创建 `.env` 文件：

```env
# MongoDB配置
MONGODB_URI=mongodb://localhost:27017/
MONGODB_DB=simplecounting

# JWT密钥
JWT_SECRET_KEY=your-secret-key-here

# Stripe配置
STRIPE_SECRET_KEY=sk_test_your_stripe_key
STRIPE_PUBLISHABLE_KEY=pk_test_your_stripe_key
STRIPE_WEBHOOK_SECRET=whsec_your_webhook_secret

# 服务器配置
FLASK_ENV=development
FLASK_PORT=5000
```

### 3. 启动服务

```bash
python app.py
```

服务将在 `http://localhost:5000` 启动。

## API文档

详细的API文档请参考 [API.md](API.md)

## 数据模型

### User（用户）
```python
{
  "_id": ObjectId,
  "username": str,
  "email": str,
  "password_hash": str,
  "avatar_url": str (optional),
  "created_at": datetime,
  "updated_at": datetime
}
```

### CountItem（计数项）
```python
{
  "_id": ObjectId,
  "user_id": ObjectId,
  "name": str,
  "count": int,
  "created_at": datetime,
  "updated_at": datetime
}
```

### Purchase（购买记录）
```python
{
  "_id": ObjectId,
  "user_id": ObjectId,
  "item_id": str,
  "amount": int,
  "currency": str,
  "payment_intent_id": str,
  "status": str,
  "created_at": datetime
}
```

## 安全性

- 密码使用 bcrypt 加密存储
- 使用 JWT 进行身份认证
- API请求需要有效的认证令牌
- 支付敏感信息通过HTTPS传输
- Stripe Webhook 签名验证

## 部署

### 使用 Docker

```bash
docker build -t simplecounting-backend .
docker run -p 5000:5000 simplecounting-backend
```

### 使用 Gunicorn

```bash
gunicorn -w 4 -b 0.0.0.0:5000 app:app
```

## 开发

### 运行测试
```bash
pytest tests/
```

### 代码格式化
```bash
black .
flake8 .
```

## 许可证

MIT License

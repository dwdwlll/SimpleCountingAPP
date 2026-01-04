"""
认证服务
"""
import bcrypt
from models import User
from utils import JWTUtils, Validators


class AuthService:
    """认证服务类"""
    
    def __init__(self, db):
        """
        初始化认证服务
        
        Args:
            db: MongoDB数据库实例
        """
        self.db = db
        self.users_collection = db['users']
    
    def register(self, username, email, password):
        """
        用户注册
        
        Args:
            username: 用户名
            email: 邮箱
            password: 密码
        
        Returns:
            (成功标志, 结果字典或错误消息)
        """
        # 验证输入
        is_valid, error = Validators.validate_username(username)
        if not is_valid:
            return False, error
        
        is_valid, error = Validators.validate_email_format(email)
        if not is_valid:
            return False, error
        
        is_valid, error = Validators.validate_password(password)
        if not is_valid:
            return False, error
        
        # 检查用户名是否已存在
        if self.users_collection.find_one({'username': username}):
            return False, "用户名已被使用"
        
        # 检查邮箱是否已存在
        if self.users_collection.find_one({'email': email}):
            return False, "邮箱已被注册"
        
        # 加密密码
        password_hash = bcrypt.hashpw(password.encode('utf-8'), bcrypt.gensalt()).decode('utf-8')
        
        # 创建用户
        user = User(username=username, email=email, password_hash=password_hash)
        self.users_collection.insert_one(user.to_mongo())
        
        # 生成JWT令牌
        token = JWTUtils.generate_token(user._id)
        
        return True, {
            'token': token,
            'user': user.to_dict()
        }
    
    def login(self, email, password):
        """
        用户登录
        
        Args:
            email: 邮箱
            password: 密码
        
        Returns:
            (成功标志, 结果字典或错误消息)
        """
        # 查找用户
        user_doc = self.users_collection.find_one({'email': email})
        if not user_doc:
            return False, "邮箱或密码错误"
        
        user = User.from_mongo(user_doc)
        
        # 验证密码
        if not bcrypt.checkpw(password.encode('utf-8'), user.password_hash.encode('utf-8')):
            return False, "邮箱或密码错误"
        
        # 生成JWT令牌
        token = JWTUtils.generate_token(user._id)
        
        return True, {
            'token': token,
            'user': user.to_dict()
        }
    
    def verify_token(self, token):
        """
        验证JWT令牌
        
        Args:
            token: JWT令牌
        
        Returns:
            用户ID或None
        """
        return JWTUtils.get_user_id_from_token(token)

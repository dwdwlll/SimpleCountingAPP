"""
JWT工具类
"""
import jwt
from datetime import datetime, timedelta
from config import Config


class JWTUtils:
    """JWT令牌工具类"""
    
    @staticmethod
    def generate_token(user_id, expiration_hours=None):
        """
        生成JWT令牌
        
        Args:
            user_id: 用户ID
            expiration_hours: 过期时间（小时），默认使用配置值
        
        Returns:
            JWT令牌字符串
        """
        if expiration_hours is None:
            expiration_hours = Config.JWT_EXPIRATION_HOURS
        
        payload = {
            'user_id': str(user_id),
            'exp': datetime.utcnow() + timedelta(hours=expiration_hours),
            'iat': datetime.utcnow()
        }
        
        token = jwt.encode(
            payload,
            Config.JWT_SECRET_KEY,
            algorithm=Config.JWT_ALGORITHM
        )
        
        return token
    
    @staticmethod
    def decode_token(token):
        """
        解码JWT令牌
        
        Args:
            token: JWT令牌字符串
        
        Returns:
            解码后的payload字典，如果失败返回None
        """
        try:
            payload = jwt.decode(
                token,
                Config.JWT_SECRET_KEY,
                algorithms=[Config.JWT_ALGORITHM]
            )
            return payload
        except jwt.ExpiredSignatureError:
            # 令牌已过期
            return None
        except jwt.InvalidTokenError:
            # 无效的令牌
            return None
    
    @staticmethod
    def get_user_id_from_token(token):
        """
        从令牌中提取用户ID
        
        Args:
            token: JWT令牌字符串
        
        Returns:
            用户ID字符串，如果失败返回None
        """
        payload = JWTUtils.decode_token(token)
        if payload:
            return payload.get('user_id')
        return None

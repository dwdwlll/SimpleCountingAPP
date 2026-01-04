"""
用户模型
"""
from datetime import datetime
from bson import ObjectId


class User:
    """用户模型类"""
    
    def __init__(self, username, email, password_hash, avatar_url=None, _id=None, 
                 created_at=None, updated_at=None):
        self._id = _id or ObjectId()
        self.username = username
        self.email = email
        self.password_hash = password_hash
        self.avatar_url = avatar_url
        self.created_at = created_at or datetime.utcnow()
        self.updated_at = updated_at or datetime.utcnow()
    
    def to_dict(self, include_sensitive=False):
        """转换为字典，可选择是否包含敏感信息"""
        data = {
            'id': str(self._id),
            'username': self.username,
            'email': self.email,
            'avatar_url': self.avatar_url,
            'created_at': self.created_at.isoformat(),
            'updated_at': self.updated_at.isoformat()
        }
        
        if include_sensitive:
            data['password_hash'] = self.password_hash
        
        return data
    
    def to_mongo(self):
        """转换为MongoDB文档格式"""
        return {
            '_id': self._id,
            'username': self.username,
            'email': self.email,
            'password_hash': self.password_hash,
            'avatar_url': self.avatar_url,
            'created_at': self.created_at,
            'updated_at': self.updated_at
        }
    
    @staticmethod
    def from_mongo(doc):
        """从MongoDB文档创建User对象"""
        if not doc:
            return None
        
        return User(
            _id=doc.get('_id'),
            username=doc.get('username'),
            email=doc.get('email'),
            password_hash=doc.get('password_hash'),
            avatar_url=doc.get('avatar_url'),
            created_at=doc.get('created_at'),
            updated_at=doc.get('updated_at')
        )

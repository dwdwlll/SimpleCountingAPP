"""
计数项模型
"""
from datetime import datetime
from bson import ObjectId


class CountItem:
    """计数项模型类"""
    
    def __init__(self, user_id, name, count=0, _id=None, 
                 created_at=None, updated_at=None):
        self._id = _id or ObjectId()
        self.user_id = ObjectId(user_id) if isinstance(user_id, str) else user_id
        self.name = name
        self.count = count
        self.created_at = created_at or datetime.utcnow()
        self.updated_at = updated_at or datetime.utcnow()
    
    def to_dict(self):
        """转换为字典"""
        return {
            'id': str(self._id),
            'user_id': str(self.user_id),
            'name': self.name,
            'count': self.count,
            'created_at': self.created_at.isoformat(),
            'updated_at': self.updated_at.isoformat()
        }
    
    def to_mongo(self):
        """转换为MongoDB文档格式"""
        return {
            '_id': self._id,
            'user_id': self.user_id,
            'name': self.name,
            'count': self.count,
            'created_at': self.created_at,
            'updated_at': self.updated_at
        }
    
    @staticmethod
    def from_mongo(doc):
        """从MongoDB文档创建CountItem对象"""
        if not doc:
            return None
        
        return CountItem(
            _id=doc.get('_id'),
            user_id=doc.get('user_id'),
            name=doc.get('name'),
            count=doc.get('count', 0),
            created_at=doc.get('created_at'),
            updated_at=doc.get('updated_at')
        )


class Purchase:
    """购买记录模型类"""
    
    def __init__(self, user_id, item_id, amount, currency, payment_intent_id,
                 status='pending', _id=None, created_at=None):
        self._id = _id or ObjectId()
        self.user_id = ObjectId(user_id) if isinstance(user_id, str) else user_id
        self.item_id = item_id
        self.amount = amount
        self.currency = currency
        self.payment_intent_id = payment_intent_id
        self.status = status  # pending, succeeded, failed
        self.created_at = created_at or datetime.utcnow()
    
    def to_dict(self):
        """转换为字典"""
        return {
            'id': str(self._id),
            'user_id': str(self.user_id),
            'item_id': self.item_id,
            'amount': self.amount,
            'currency': self.currency,
            'payment_intent_id': self.payment_intent_id,
            'status': self.status,
            'created_at': self.created_at.isoformat()
        }
    
    def to_mongo(self):
        """转换为MongoDB文档格式"""
        return {
            '_id': self._id,
            'user_id': self.user_id,
            'item_id': self.item_id,
            'amount': self.amount,
            'currency': self.currency,
            'payment_intent_id': self.payment_intent_id,
            'status': self.status,
            'created_at': self.created_at
        }
    
    @staticmethod
    def from_mongo(doc):
        """从MongoDB文档创建Purchase对象"""
        if not doc:
            return None
        
        return Purchase(
            _id=doc.get('_id'),
            user_id=doc.get('user_id'),
            item_id=doc.get('item_id'),
            amount=doc.get('amount'),
            currency=doc.get('currency'),
            payment_intent_id=doc.get('payment_intent_id'),
            status=doc.get('status', 'pending'),
            created_at=doc.get('created_at')
        )

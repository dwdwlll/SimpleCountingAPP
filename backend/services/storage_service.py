"""
数据存储服务
"""
from datetime import datetime
from bson import ObjectId
from models import User, CountItem
from utils import Validators


class StorageService:
    """数据存储服务类"""
    
    def __init__(self, db):
        """
        初始化存储服务
        
        Args:
            db: MongoDB数据库实例
        """
        self.db = db
        self.users_collection = db['users']
        self.count_items_collection = db['count_items']
    
    # 用户相关方法
    def get_user(self, user_id):
        """获取用户信息"""
        user_obj_id = ObjectId(user_id) if isinstance(user_id, str) else user_id
        user_doc = self.users_collection.find_one({'_id': user_obj_id})
        return User.from_mongo(user_doc) if user_doc else None
    
    def update_user(self, user_id, update_data):
        """
        更新用户信息
        
        Args:
            user_id: 用户ID
            update_data: 更新数据字典
        
        Returns:
            (成功标志, 更新后的用户或错误消息)
        """
        user_obj_id = ObjectId(user_id) if isinstance(user_id, str) else user_id
        
        # 验证更新数据
        if 'username' in update_data:
            is_valid, error = Validators.validate_username(update_data['username'])
            if not is_valid:
                return False, error
            
            # 检查用户名是否已被使用（排除当前用户）
            existing = self.users_collection.find_one({
                'username': update_data['username'],
                '_id': {'$ne': user_obj_id}
            })
            if existing:
                return False, "用户名已被使用"
        
        # 添加更新时间
        update_data['updated_at'] = datetime.utcnow()
        
        # 更新用户
        result = self.users_collection.update_one(
            {'_id': user_obj_id},
            {'$set': update_data}
        )
        
        if result.modified_count == 0:
            return False, "更新失败"
        
        user = self.get_user(user_id)
        return True, user
    
    # 计数项相关方法
    def get_count_items(self, user_id):
        """获取用户的所有计数项"""
        user_obj_id = ObjectId(user_id) if isinstance(user_id, str) else user_id
        items = self.count_items_collection.find({'user_id': user_obj_id})
        return [CountItem.from_mongo(item).to_dict() for item in items]
    
    def get_count_item(self, user_id, item_id):
        """获取单个计数项"""
        user_obj_id = ObjectId(user_id) if isinstance(user_id, str) else user_id
        item_obj_id = ObjectId(item_id) if isinstance(item_id, str) else item_id
        
        item_doc = self.count_items_collection.find_one({
            '_id': item_obj_id,
            'user_id': user_obj_id
        })
        return CountItem.from_mongo(item_doc) if item_doc else None
    
    def create_count_item(self, user_id, name, count=0):
        """
        创建计数项
        
        Args:
            user_id: 用户ID
            name: 计数项名称
            count: 初始计数值
        
        Returns:
            (成功标志, 计数项对象或错误消息)
        """
        # 验证名称
        is_valid, error = Validators.validate_count_item_name(name)
        if not is_valid:
            return False, error
        
        # 验证计数值
        is_valid, error = Validators.validate_count_value(count)
        if not is_valid:
            return False, error
        
        # 创建计数项
        item = CountItem(user_id=user_id, name=name, count=count)
        self.count_items_collection.insert_one(item.to_mongo())
        
        return True, item
    
    def update_count_item(self, user_id, item_id, update_data):
        """
        更新计数项
        
        Args:
            user_id: 用户ID
            item_id: 计数项ID
            update_data: 更新数据字典
        
        Returns:
            (成功标志, 更新后的计数项或错误消息)
        """
        user_obj_id = ObjectId(user_id) if isinstance(user_id, str) else user_id
        item_obj_id = ObjectId(item_id) if isinstance(item_id, str) else item_id
        
        # 验证数据
        if 'name' in update_data:
            is_valid, error = Validators.validate_count_item_name(update_data['name'])
            if not is_valid:
                return False, error
        
        if 'count' in update_data:
            is_valid, error = Validators.validate_count_value(update_data['count'])
            if not is_valid:
                return False, error
        
        # 添加更新时间
        update_data['updated_at'] = datetime.utcnow()
        
        # 更新计数项
        result = self.count_items_collection.update_one(
            {'_id': item_obj_id, 'user_id': user_obj_id},
            {'$set': update_data}
        )
        
        if result.matched_count == 0:
            return False, "计数项不存在"
        
        item = self.get_count_item(user_id, item_id)
        return True, item
    
    def delete_count_item(self, user_id, item_id):
        """删除计数项"""
        user_obj_id = ObjectId(user_id) if isinstance(user_id, str) else user_id
        item_obj_id = ObjectId(item_id) if isinstance(item_id, str) else item_id
        
        result = self.count_items_collection.delete_one({
            '_id': item_obj_id,
            'user_id': user_obj_id
        })
        
        return result.deleted_count > 0
    
    def sync_count_items(self, user_id, items_data):
        """
        同步计数项（批量创建或更新）
        
        Args:
            user_id: 用户ID
            items_data: 计数项数据列表
        
        Returns:
            (成功标志, 同步后的计数项列表或错误消息)
        """
        user_obj_id = ObjectId(user_id) if isinstance(user_id, str) else user_id
        
        try:
            for item_data in items_data:
                name = item_data.get('name')
                count = item_data.get('count', 0)
                
                # 验证数据
                is_valid, error = Validators.validate_count_item_name(name)
                if not is_valid:
                    continue
                
                is_valid, error = Validators.validate_count_value(count)
                if not is_valid:
                    continue
                
                # 查找是否已存在同名计数项
                existing = self.count_items_collection.find_one({
                    'user_id': user_obj_id,
                    'name': name
                })
                
                if existing:
                    # 更新现有计数项
                    self.count_items_collection.update_one(
                        {'_id': existing['_id']},
                        {'$set': {'count': count, 'updated_at': datetime.utcnow()}}
                    )
                else:
                    # 创建新计数项
                    item = CountItem(user_id=user_id, name=name, count=count)
                    self.count_items_collection.insert_one(item.to_mongo())
            
            # 返回所有计数项
            items = self.get_count_items(user_id)
            return True, items
        
        except Exception as e:
            return False, f"同步失败: {str(e)}"

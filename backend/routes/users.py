"""
用户信息路由
"""
from flask import Blueprint, request, jsonify
from functools import wraps
from services import AuthService, StorageService

users_bp = Blueprint('users', __name__, url_prefix='/api/users')


def require_auth(f):
    """认证装饰器"""
    @wraps(f)
    def decorated_function(*args, **kwargs):
        token = None
        auth_header = request.headers.get('Authorization')
        
        if auth_header:
            try:
                token = auth_header.split(' ')[1]  # Bearer <token>
            except IndexError:
                return jsonify({'error': '无效的认证头'}), 401
        
        if not token:
            return jsonify({'error': '缺少认证令牌'}), 401
        
        user_id = AuthService(request.db).verify_token(token)
        if not user_id:
            return jsonify({'error': '无效或过期的令牌'}), 401
        
        request.user_id = user_id
        return f(*args, **kwargs)
    
    return decorated_function


def init_users_routes(db):
    """初始化用户路由"""
    storage_service = StorageService(db)
    
    @users_bp.before_request
    def before_request():
        request.db = db
    
    @users_bp.route('/me', methods=['GET'])
    @require_auth
    def get_current_user():
        """获取当前用户信息"""
        user = storage_service.get_user(request.user_id)
        
        if not user:
            return jsonify({'error': '用户不存在'}), 404
        
        return jsonify(user.to_dict()), 200
    
    @users_bp.route('/me', methods=['PUT'])
    @require_auth
    def update_current_user():
        """更新当前用户信息"""
        data = request.get_json()
        
        # 只允许更新特定字段
        allowed_fields = ['username', 'avatar_url']
        update_data = {k: v for k, v in data.items() if k in allowed_fields}
        
        if not update_data:
            return jsonify({'error': '没有可更新的字段'}), 400
        
        success, result = storage_service.update_user(request.user_id, update_data)
        
        if success:
            return jsonify(result.to_dict()), 200
        else:
            return jsonify({'error': result}), 400
    
    return users_bp

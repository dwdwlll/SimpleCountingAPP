"""
认证路由
"""
from flask import Blueprint, request, jsonify
from services import AuthService

auth_bp = Blueprint('auth', __name__, url_prefix='/api/auth')


def init_auth_routes(db):
    """初始化认证路由"""
    auth_service = AuthService(db)
    
    @auth_bp.route('/register', methods=['POST'])
    def register():
        """用户注册"""
        data = request.get_json()
        
        username = data.get('username')
        email = data.get('email')
        password = data.get('password')
        
        if not all([username, email, password]):
            return jsonify({'error': '缺少必要字段'}), 400
        
        success, result = auth_service.register(username, email, password)
        
        if success:
            return jsonify(result), 201
        else:
            return jsonify({'error': result}), 400
    
    @auth_bp.route('/login', methods=['POST'])
    def login():
        """用户登录"""
        data = request.get_json()
        
        email = data.get('email')
        password = data.get('password')
        
        if not all([email, password]):
            return jsonify({'error': '缺少必要字段'}), 400
        
        success, result = auth_service.login(email, password)
        
        if success:
            return jsonify(result), 200
        else:
            return jsonify({'error': result}), 401
    
    return auth_bp

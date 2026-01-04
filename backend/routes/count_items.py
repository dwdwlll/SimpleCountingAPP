"""
计数数据路由
"""
from flask import Blueprint, request, jsonify
from routes.users import require_auth
from services import StorageService

count_items_bp = Blueprint('count_items', __name__, url_prefix='/api/count-items')


def init_count_items_routes(db):
    """初始化计数项路由"""
    storage_service = StorageService(db)
    
    @count_items_bp.before_request
    def before_request():
        request.db = db
    
    @count_items_bp.route('', methods=['GET'])
    @require_auth
    def get_count_items():
        """获取所有计数项"""
        items = storage_service.get_count_items(request.user_id)
        return jsonify(items), 200
    
    @count_items_bp.route('', methods=['POST'])
    @require_auth
    def create_count_item():
        """创建计数项"""
        data = request.get_json()
        
        name = data.get('name')
        count = data.get('count', 0)
        
        if not name:
            return jsonify({'error': '缺少计数项名称'}), 400
        
        success, result = storage_service.create_count_item(request.user_id, name, count)
        
        if success:
            return jsonify(result.to_dict()), 201
        else:
            return jsonify({'error': result}), 400
    
    @count_items_bp.route('/<item_id>', methods=['GET'])
    @require_auth
    def get_count_item(item_id):
        """获取单个计数项"""
        item = storage_service.get_count_item(request.user_id, item_id)
        
        if not item:
            return jsonify({'error': '计数项不存在'}), 404
        
        return jsonify(item.to_dict()), 200
    
    @count_items_bp.route('/<item_id>', methods=['PUT'])
    @require_auth
    def update_count_item(item_id):
        """更新计数项"""
        data = request.get_json()
        
        # 只允许更新特定字段
        allowed_fields = ['name', 'count']
        update_data = {k: v for k, v in data.items() if k in allowed_fields}
        
        if not update_data:
            return jsonify({'error': '没有可更新的字段'}), 400
        
        success, result = storage_service.update_count_item(request.user_id, item_id, update_data)
        
        if success:
            return jsonify(result.to_dict()), 200
        else:
            return jsonify({'error': result}), 400
    
    @count_items_bp.route('/<item_id>', methods=['DELETE'])
    @require_auth
    def delete_count_item(item_id):
        """删除计数项"""
        success = storage_service.delete_count_item(request.user_id, item_id)
        
        if success:
            return jsonify({'message': '删除成功'}), 200
        else:
            return jsonify({'error': '计数项不存在'}), 404
    
    @count_items_bp.route('/sync', methods=['POST'])
    @require_auth
    def sync_count_items():
        """同步计数项"""
        data = request.get_json()
        items_data = data.get('items', [])
        
        if not items_data:
            return jsonify({'error': '缺少同步数据'}), 400
        
        success, result = storage_service.sync_count_items(request.user_id, items_data)
        
        if success:
            return jsonify({'items': result}), 200
        else:
            return jsonify({'error': result}), 400
    
    return count_items_bp

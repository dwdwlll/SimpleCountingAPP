"""
Flask应用主文件
"""
from flask import Flask
from flask_cors import CORS
from pymongo import MongoClient
from config import config
from routes import (
    init_auth_routes,
    init_users_routes,
    init_count_items_routes,
    init_payments_routes
)
import os


def create_app(config_name='default'):
    """
    创建Flask应用
    
    Args:
        config_name: 配置名称
    
    Returns:
        Flask应用实例
    """
    app = Flask(__name__)
    
    # 加载配置
    app.config.from_object(config[config_name])
    config[config_name].init_app(app)
    
    # 启用CORS
    CORS(app, resources={r"/api/*": {"origins": "*"}})
    
    # 连接MongoDB
    client = MongoClient(app.config['MONGODB_URI'])
    db = client[app.config['MONGODB_DB']]
    
    # 注册蓝图
    app.register_blueprint(init_auth_routes(db))
    app.register_blueprint(init_users_routes(db))
    app.register_blueprint(init_count_items_routes(db))
    app.register_blueprint(init_payments_routes(db))
    
    # 健康检查路由
    @app.route('/health')
    def health_check():
        return {'status': 'ok', 'message': 'SimpleCountingAPP Backend is running'}, 200
    
    # 根路由
    @app.route('/')
    def index():
        return {
            'name': 'SimpleCountingAPP Backend API',
            'version': '1.0.0',
            'endpoints': {
                'auth': '/api/auth',
                'users': '/api/users',
                'count_items': '/api/count-items',
                'payments': '/api/payments',
                'health': '/health'
            }
        }, 200
    
    return app


if __name__ == '__main__':
    # 从环境变量获取配置
    env = os.getenv('FLASK_ENV', 'development')
    app = create_app(env)
    
    # 运行应用
    port = app.config.get('PORT', 5000)
    debug = app.config.get('DEBUG', True)
    
    print(f"Starting SimpleCountingAPP Backend on port {port}")
    print(f"Environment: {env}")
    print(f"Debug mode: {debug}")
    
    app.run(host='0.0.0.0', port=port, debug=debug)

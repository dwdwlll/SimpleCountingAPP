"""
路由包初始化
"""
from .auth import init_auth_routes
from .users import init_users_routes
from .count_items import init_count_items_routes
from .payments import init_payments_routes

__all__ = [
    'init_auth_routes',
    'init_users_routes',
    'init_count_items_routes',
    'init_payments_routes'
]

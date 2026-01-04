"""
数据验证工具
"""
import re
from email_validator import validate_email, EmailNotValidError


class Validators:
    """数据验证工具类"""
    
    @staticmethod
    def validate_email_format(email):
        """
        验证邮箱格式
        
        Args:
            email: 邮箱地址字符串
        
        Returns:
            (是否有效, 错误消息)
        """
        try:
            valid = validate_email(email)
            return True, None
        except EmailNotValidError as e:
            return False, str(e)
    
    @staticmethod
    def validate_username(username):
        """
        验证用户名
        规则：3-20个字符，只能包含字母、数字、下划线和中文
        
        Args:
            username: 用户名字符串
        
        Returns:
            (是否有效, 错误消息)
        """
        if not username:
            return False, "用户名不能为空"
        
        if len(username) < 3 or len(username) > 20:
            return False, "用户名长度必须在3-20个字符之间"
        
        # 允许字母、数字、下划线和中文
        pattern = r'^[\w\u4e00-\u9fa5]+$'
        if not re.match(pattern, username):
            return False, "用户名只能包含字母、数字、下划线和中文"
        
        return True, None
    
    @staticmethod
    def validate_password(password):
        """
        验证密码强度
        规则：至少8个字符
        
        Args:
            password: 密码字符串
        
        Returns:
            (是否有效, 错误消息)
        """
        if not password:
            return False, "密码不能为空"
        
        if len(password) < 8:
            return False, "密码长度至少为8个字符"
        
        return True, None
    
    @staticmethod
    def validate_count_item_name(name):
        """
        验证计数项名称
        
        Args:
            name: 计数项名称字符串
        
        Returns:
            (是否有效, 错误消息)
        """
        if not name:
            return False, "计数项名称不能为空"
        
        if len(name) > 50:
            return False, "计数项名称不能超过50个字符"
        
        return True, None
    
    @staticmethod
    def validate_count_value(count):
        """
        验证计数值
        
        Args:
            count: 计数值
        
        Returns:
            (是否有效, 错误消息)
        """
        if not isinstance(count, int):
            return False, "计数值必须是整数"
        
        if count < 0:
            return False, "计数值不能为负数"
        
        if count > 9999:
            return False, "计数值不能超过9999"
        
        return True, None

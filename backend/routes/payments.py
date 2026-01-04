"""
支付路由
"""
from flask import Blueprint, request, jsonify
from routes.users import require_auth
from services import PaymentService

payments_bp = Blueprint('payments', __name__, url_prefix='/api/payments')


def init_payments_routes(db):
    """初始化支付路由"""
    payment_service = PaymentService(db)
    
    @payments_bp.before_request
    def before_request():
        request.db = db
    
    @payments_bp.route('/create-intent', methods=['POST'])
    @require_auth
    def create_payment_intent():
        """创建支付意图"""
        data = request.get_json()
        
        item_id = data.get('item_id')
        amount = data.get('amount')
        currency = data.get('currency', 'usd')
        
        if not all([item_id, amount]):
            return jsonify({'error': '缺少必要字段'}), 400
        
        success, result = payment_service.create_payment_intent(
            request.user_id,
            item_id,
            amount,
            currency
        )
        
        if success:
            return jsonify(result), 200
        else:
            return jsonify({'error': result}), 400
    
    @payments_bp.route('/confirm', methods=['POST'])
    @require_auth
    def confirm_payment():
        """确认支付"""
        data = request.get_json()
        payment_intent_id = data.get('payment_intent_id')
        
        if not payment_intent_id:
            return jsonify({'error': '缺少支付意图ID'}), 400
        
        success, result = payment_service.confirm_payment(payment_intent_id)
        
        if success:
            return jsonify(result), 200
        else:
            return jsonify({'error': result}), 400
    
    @payments_bp.route('/webhook', methods=['POST'])
    def stripe_webhook():
        """处理Stripe Webhook"""
        payload = request.data
        signature = request.headers.get('Stripe-Signature')
        
        if not signature:
            return jsonify({'error': '缺少签名'}), 400
        
        success, result = payment_service.handle_webhook(payload, signature)
        
        if success:
            return jsonify(result), 200
        else:
            return jsonify({'error': result}), 400
    
    @payments_bp.route('/purchases', methods=['GET'])
    @require_auth
    def get_purchases():
        """获取用户购买记录"""
        purchases = payment_service.get_user_purchases(request.user_id)
        return jsonify({'purchases': purchases}), 200
    
    return payments_bp

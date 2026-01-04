"""
支付服务
"""
import stripe
from config import Config
from models import Purchase
from bson import ObjectId


class PaymentService:
    """支付服务类"""
    
    def __init__(self, db):
        """
        初始化支付服务
        
        Args:
            db: MongoDB数据库实例
        """
        self.db = db
        self.purchases_collection = db['purchases']
        stripe.api_key = Config.STRIPE_SECRET_KEY
    
    def create_payment_intent(self, user_id, item_id, amount, currency='usd'):
        """
        创建支付意图
        
        Args:
            user_id: 用户ID
            item_id: 商品ID
            amount: 金额（分）
            currency: 货币类型
        
        Returns:
            (成功标志, 结果字典或错误消息)
        """
        try:
            # 验证金额
            if amount <= 0:
                return False, "金额必须大于0"
            
            # 创建Stripe支付意图
            intent = stripe.PaymentIntent.create(
                amount=amount,
                currency=currency,
                metadata={
                    'user_id': str(user_id),
                    'item_id': item_id
                }
            )
            
            # 保存购买记录
            purchase = Purchase(
                user_id=user_id,
                item_id=item_id,
                amount=amount,
                currency=currency,
                payment_intent_id=intent.id,
                status='pending'
            )
            self.purchases_collection.insert_one(purchase.to_mongo())
            
            return True, {
                'client_secret': intent.client_secret,
                'payment_intent_id': intent.id
            }
        
        except stripe.error.StripeError as e:
            return False, f"支付错误: {str(e)}"
        except Exception as e:
            return False, f"创建支付意图失败: {str(e)}"
    
    def confirm_payment(self, payment_intent_id):
        """
        确认支付
        
        Args:
            payment_intent_id: 支付意图ID
        
        Returns:
            (成功标志, 结果字典或错误消息)
        """
        try:
            # 从Stripe获取支付意图
            intent = stripe.PaymentIntent.retrieve(payment_intent_id)
            
            # 更新购买记录状态
            status = 'succeeded' if intent.status == 'succeeded' else 'failed'
            self.purchases_collection.update_one(
                {'payment_intent_id': payment_intent_id},
                {'$set': {'status': status}}
            )
            
            return True, {
                'status': status,
                'payment_intent_id': payment_intent_id
            }
        
        except stripe.error.StripeError as e:
            return False, f"支付错误: {str(e)}"
        except Exception as e:
            return False, f"确认支付失败: {str(e)}"
    
    def handle_webhook(self, payload, signature):
        """
        处理Stripe Webhook
        
        Args:
            payload: Webhook负载
            signature: Stripe签名
        
        Returns:
            (成功标志, 结果字典或错误消息)
        """
        try:
            event = stripe.Webhook.construct_event(
                payload,
                signature,
                Config.STRIPE_WEBHOOK_SECRET
            )
            
            if event['type'] == 'payment_intent.succeeded':
                payment_intent = event['data']['object']
                
                # 更新购买记录状态
                self.purchases_collection.update_one(
                    {'payment_intent_id': payment_intent['id']},
                    {'$set': {'status': 'succeeded'}}
                )
                
                return True, {'message': '支付成功处理'}
            
            elif event['type'] == 'payment_intent.payment_failed':
                payment_intent = event['data']['object']
                
                # 更新购买记录状态
                self.purchases_collection.update_one(
                    {'payment_intent_id': payment_intent['id']},
                    {'$set': {'status': 'failed'}}
                )
                
                return True, {'message': '支付失败处理'}
            
            return True, {'message': 'Webhook已接收'}
        
        except stripe.error.SignatureVerificationError:
            return False, "无效的webhook签名"
        except Exception as e:
            return False, f"处理webhook失败: {str(e)}"
    
    def get_user_purchases(self, user_id):
        """
        获取用户的购买记录
        
        Args:
            user_id: 用户ID
        
        Returns:
            购买记录列表
        """
        user_obj_id = ObjectId(user_id) if isinstance(user_id, str) else user_id
        purchases = self.purchases_collection.find({'user_id': user_obj_id})
        return [Purchase.from_mongo(p).to_dict() for p in purchases]

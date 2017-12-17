class User < ApplicationRecord
  attr_accessor :remember_token, :activation_token, :reset_token#虛擬屬性（不是存在資料庫裡）
  before_save :downcase_email
  before_create :create_activation_digest#before_create只有使用new方法時會調用,before_save則是update時也會
  validates :name, presence: true, length: { maximum: 50 }
  VALID_EMAIL_REGEX = /\A[\w+\-.]+@[a-z\d\-]+(\.[a-z\d\-]+)*\.[a-z]+\z/i
  validates :email, presence: true, length: { maximum: 255 }, 
                         format: { with: VALID_EMAIL_REGEX },
                         uniqueness: { case_sensitive: false }

  has_secure_password
  validates :password, presence: true, length: { minimum: 6 }, allow_nil: true
  # 返回指定字符串的哈希摘要
  def User.digest(string)
    cost = ActiveModel::SecurePassword.min_cost ? BCrypt::Engine::MIN_COST :
                                                  BCrypt::Engine.cost
    BCrypt::Password.create(string, cost: cost)
  end

  # 返回一个随机令牌
  def User.new_token
    SecureRandom.urlsafe_base64
  end
  # 为了持久保存会话，在数据库中记住用户,實例呼叫此方法時會隨機產生一個令牌，再轉化成摘要存入資料庫，作為辨認的摘要
  def remember
    self.remember_token = User.new_token
    update_attribute(:remember_digest, User.digest(remember_token))
  end

  # 如果指定的令牌和摘要匹配，返回 true
  def authenticated?(attribute, token)
    digest = send("#{attribute}_digest")
    return false if digest.nil?
    BCrypt::Password.new(digest).is_password?(token)
  end

  def forget
    update_attribute(:remember_digest, nil)#self.update_attribute()
  end

  def activate
    
    update_columns(activated: true, activated_at: Time.zone.now)#此方法會跳過驗證
  end

  def send_activation_email
    UserMailer.account_activation(self).deliver_now
  end

  def create_reset_digest
    self.reset_token = User.new_token
    
    update_columns(reset_digest:  User.digest(reset_token), reset_sent_at: Time.zone.now)
  end

  def send_password_reset_email
    UserMailer.password_reset(self).deliver_now
  end

  def password_reset_expired?
    reset_sent_at < 2.hours.ago
  end

  private 
    def downcase_email
      self.email.downcase!
    end

    def create_activation_digest#創造一個新的激活摘要
      self.activation_token = User.new_token
      self.activation_digest = User.digest(activation_token)
    end
end

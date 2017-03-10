class User < ApplicationRecord

  #provides database constraints
  before_save :downcase_email
  #confirmation email
  before_create :create_activation_digest
  #provides getters and setters 
  attr_accessor :remember_token, :activation_token
  #checks these settings and returns if the user is valid or not
  validates :name,  presence: true, length: { maximum: 50 }
  VALID_EMAIL_REGEX = /\A[\w+\-.]+@[a-z\d\-.]+\.[a-z]+\z/i
  validates :email, presence: true, length: { maximum: 255 },
                    format: { with: VALID_EMAIL_REGEX },
                    uniqueness: { case_sensitive: false } #true is implied with case sensitive
  has_secure_password
  validates :password, presence: true, length: { minimum: 6 }, allow_nil: true

  # Returns the hash digest of the given string, secures a password
  def User.digest(string)
    cost = ActiveModel::SecurePassword.min_cost ? BCrypt::Engine::MIN_COST :
                                                  BCrypt::Engine.cost
    BCrypt::Password.create(string, cost: cost)
  end
  
  def downcase_email
    self.email = email.downcase
  end
  
  #creates and assigns the activation token and digest
  def create_activation_digest
    self.activation_token = User.new_token
    self.activation_digest = User.digest(activation_token)
  end
  

  # Returns a random token used as a key for remembering sessions 
  def User.new_token
    SecureRandom.urlsafe_base64
  end
  
  # remembers a user
  def remember
    self.remember_token = User.new_token
    update_attribute(:remember_digest, User.digest(remember_token)) #no password authentication?
  end
  
  def forget
    update_attribute(:remember_digest, nil)
  end
  
   # Returns true if the given token matches the digest. Verifies that the user retrieved from the database is the correct user
  # Returns true if the given token matches the digest.
  def authenticated?(attribute, token)
    digest = send("#{attribute}_digest") #HOLY METAPROGRAMMING calls (BLANK_digest on this)
    return false if digest.nil?
    BCrypt::Password.new(digest).is_password?(token)
  end
  
  def activate
    update_columns(activated: true, activated_at: Time.zone.now)
  end
  
  def send_activation_email
    UserMailer.account_activation(self).deliver_now
  end
end
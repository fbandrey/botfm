require 'digest/sha1'
class User < ActiveRecord::Base
  # Virtual attribute for the unencrypted password
  attr_accessor :password

  COLOR_THEMES = {
    0 => "yellow",
    1 => "green",
    2 => "pink",
    3 => "gray"
  }

  has_and_belongs_to_many :roles
  has_many :songs, :dependent => :destroy, :order => "created_at DESC"
  has_many :sounds, :dependent => :destroy, :order => "created_at DESC"
  has_one :photo, :dependent => :destroy

  named_scope :active,  :conditions => "have_ban = false"
  named_scope :with_content, :conditions => "EXISTS(SELECT 1 FROM songs WHERE user_id = users.id) OR EXISTS(SELECT 1 FROM sounds WHERE user_id = users.id)"

  #named_scope :paid, :conditions => "EXISTS(SELECT 1 FROM institute_placements WHERE now()::date BETWEEN institute_placements.start_date AND institute_placements.stop_date AND institute_id = institutes.id)"

  validates_presence_of     :login, :message => "|Введите логин"
  validates_presence_of     :email, :message => "|Введите электронную почту"
  validates_presence_of     :name, :message => "|Введите Ваш ник"
  validates_presence_of     :description, :message => "|Введите описание боткаста"

  validates_format_of :login, :with => /^[a-z0-9]+$/, :message => "|Логин содержит недопустимые символы"

  validates_presence_of     :password,                   :if => :password_required?, :message => "|Введите пароль"
  validates_presence_of     :password_confirmation,      :if => :password_required?, :message => "|Введите подтверждение пароля"
  validates_length_of       :password, :within => 4..40, :if => :password_required?, :message => "|Пароль должен быть от 4 до 40 знаков"
  validates_confirmation_of :password,                   :if => :password_required?, :message => "|Введены разные пароли"

  validates_length_of       :login,    :within => 3..40,        :message => "|Логин должен быть от 3 до 40 знаков"
  validates_length_of       :email,    :within => 5..100,       :message => "|Почта должна быть от 5 до 100 знаков"

  validates_uniqueness_of   :name,  :case_sensitive => false,   :message => "|Пользователь с таким ником уже зарегистрирован"
  validates_uniqueness_of   :login, :case_sensitive => false,   :message => "|Пользователь с таким логином уже зарегистрирован"
  validates_uniqueness_of   :email, :case_sensitive => false,   :message => "|Пользователь с такой почтой уже зарегистрирован"
  before_save :encrypt_password
  
  # prevents a user from submitting a crafted form that bypasses activation
  # anything else you want your user to change should be added here.
  attr_accessible :login, :is_admin, :email, :password, :password_confirmation, :skype, :twitter, :icq, :color_theme, :homepage, :myspace, :facebook, :promodj, :description, :name
  
  # Authenticates a user by their login name and unencrypted password.  Returns the user or nil.
  def self.authenticate(login, password)
    u = find_by_login(login) # need to get the salt
    u && u.authenticated?(password) ? u : nil
  end

  def gain_rating
    ttime = self.rating_update + 10.seconds
    if DateTime.now.utc > ttime.utc
      self.update_attribute("rating", self.rating + 1) 
      self.update_attribute("rating_update", DateTime.now.utc)
      return true
    else
      return false
    end
  end

  # Encrypts some data with the salt.
  def self.encrypt(password, salt)
    Digest::SHA1.hexdigest("--#{salt}--#{password}--")
  end

  # Encrypts the password with the user salt
  def encrypt(password)
    self.class.encrypt(password, salt)
  end

  def self.random_password(size = 8)
    chars = (('a'..'z').to_a + ('0'..'9').to_a) - %w(i o 0 1 l 0)
    (1..size).collect{|a| chars[rand(chars.size)] }.join
  end

  def authenticated?(password)
    crypted_password == encrypt(password)
  end

  def remember_token?
    remember_token_expires_at && Time.now.utc < remember_token_expires_at 
  end

  # These create and unset the fields required for remembering users between browser closes
  def remember_me
    remember_me_for 2.weeks
  end

  def remember_me_for(time)
    remember_me_until time.from_now.utc
  end

  def remember_me_until(time)
    self.remember_token_expires_at = time
    self.remember_token            = encrypt("#{email}--#{remember_token_expires_at}")
    save(false)
  end

  def forget_me
    self.remember_token_expires_at = nil
    self.remember_token            = nil
    save(false)
  end

  protected
    # before filter 
    def encrypt_password
      return if password.blank?
      self.salt = Digest::SHA1.hexdigest("--#{Time.now.to_s}--#{login}--") if new_record?
      self.crypted_password = encrypt(password)
    end
    
    def password_required?
      crypted_password.blank? || !password.blank?
    end
    
end

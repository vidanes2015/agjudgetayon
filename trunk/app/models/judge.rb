class Judge < ActiveRecord::Base
  has_and_belongs_to_many :rounds, :order=>'ordering'
  has_many :scores
  
  validates_presence_of :username, :alias, :name
  validates_uniqueness_of :username, :alias
  
  attr_accessor :password_confirmation
  validates_confirmation_of :password
  
  validate :password_non_blank
  validate :username_not_admin
  
  def password
    @password
  end
  
  def password=(pwd)
    @password = pwd
    return if pwd.blank?
    create_new_salt
    self.hashed_password = Judge.encrypted_password(self.password, self.salt)
  end
  
  def self.authenticate(username, password)
    judge = self.find_by_username(username)
    if judge
      expected_password = encrypted_password(password, judge.salt)
      if judge.hashed_password != expected_password
        judge = nil
      end
    end
    judge
  end
  
private
  def password_non_blank
    errors.add_to_base("Missing password") if hashed_password.blank?
  end
  
  def username_not_admin
    errors.add_to_base("Username cannot be admin") if username == "admin"
  end
  
  def self.encrypted_password(password, salt)
    string_to_hash = password + "wibble" + salt
    Digest::SHA1.hexdigest(string_to_hash)
  end
  
  def create_new_salt
    self.salt = self.object_id.to_s + rand.to_s
  end
    
end

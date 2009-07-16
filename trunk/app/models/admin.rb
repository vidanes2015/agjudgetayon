class Admin < ActiveRecord::Base

  attr_accessor :password_confirmation
  validates_confirmation_of :password
  
  validate :password_non_blank
  
  def password
    @password
  end
  
  def password=(pwd)
    @password = pwd
    return if pwd.blank?
    create_new_salt
    self.hashed_password = Admin.encrypted_password(self.password, self.salt)
  end
  
  def self.authenticate(password)
    admin = Admin.find(:all)[0]
    if admin
      expected_password = encrypted_password(password, admin.salt)
      if admin.hashed_password != expected_password
        admin = nil
      end
    end
    admin
  end
  
private
  def password_non_blank
    errors.add_to_base("Missing password") if hashed_password.blank?
  end
  
  def self.encrypted_password(password, salt)
    string_to_hash = password + "wibble" + salt
    Digest::SHA1.hexdigest(string_to_hash)
  end
  
  def create_new_salt
    self.salt = self.object_id.to_s + rand.to_s
  end
    
end

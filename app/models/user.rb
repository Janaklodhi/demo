# app/models/user.rb
class User < ApplicationRecord
    validates :username, presence: true
    validates :email, presence: true, uniqueness: true, format: { with: URI::MailTo::EMAIL_REGEXP }
    validates :password, presence: true, length: { minimum: 6 }
    validates :confirm_password, presence: true
    validate :password_confirmation_match
  
    private
  
    def password_confirmation_match
      errors.add(:confirm_password, "doesn't match Password") unless password == confirm_password
    end
  end
  
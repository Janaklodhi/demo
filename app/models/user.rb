# app/models/user.rb
class User < ApplicationRecord
    validates :username, presence: true, uniqueness: true
    validates :email, presence: true, uniqueness: true, format: { with: URI::MailTo::EMAIL_REGEXP }
    validates :password, presence: true, length: { minimum: 6 }
    validates :confirm_password, presence: true
    enum account_type: { student: 'student', teacher: 'teacher', admin: 'admin' }, _default: 'student'
    validate :valid_account_type
    # validate :password_confirmation_match
    def generate_password_token!
      self.reset_password_token = generate_token
      self.reset_password_sent_at = Time.now.utc
      save
    end

    private

    def valid_account_type
      unless %w(student teacher admin).include?(account_type)
        errors.add(:account_type, "this is not a valid account type")
      end
    end

    
    # def password_confirmation_match
    #   byebug
    #   errors.add(:confirm_password, "doesn't match Password") unless password == confirm_password
    # end

    def generate_token
      SecureRandom.hex(10)
    end

    def save_tokens
      update_columns(reset_password_token: self.reset_password_token, reset_password_sent_at: self.reset_password_sent_at)
    end
  end
  
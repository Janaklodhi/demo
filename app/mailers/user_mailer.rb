class UserMailer < ApplicationMailer
    def password_reset_email(user)
        @user = user
        mail(to: @user.email, subject: "reset your password")
    end
end
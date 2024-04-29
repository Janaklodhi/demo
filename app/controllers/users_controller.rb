class UsersController < ApplicationController
    def signup
      @user = User.new(user_params)
      if @user.save
        render json: @user
      else
        render json: {error:  @user.errors.full_messages }, status: :unprocessable_entity
      end
    end
    
    def login
      user = user_params
      @user = User.find_by(username: user[:username])
      begin
        if @user&.password == user[:password]
          token = encode_data({ user_data: @user.id })
          render json: { user: user, token: token }
        else
          render json: { message: "Invalid credentials" }, status: :unauthorized
        end
      rescue => e
        render json: { message: "An error occurred: #{e.message}" }, status: :unprocessable_entity
      end
    end

    def forgot_password
      email_param = params[:email]
      @user = User.find_by(email: email_param)
      if @user.present?
        @user.generate_password_token!
        UserMailer.password_reset_email(@user).deliver_now
        render json: { message: "Password reset instructions sent successfully " }
      else
        render json: { error: "User not found with email" }, status: :not_found
      end
    end
  
    def reset_password
      token = params[:token]
      user = User.find_by(reset_password_token: token)
      if user && !expired?(token)
        if params[:password].present? && params[:password_confirmation].present?
          if params[:password] == params[:password_confirmation]
            if user.update(password: params[:password])
              user.update(reset_password_token: nil)
              render json: { message: "Password successfully updated" }
            else
              render json: { errors: user.errors.full_messages }, status: :unprocessable_entity
            end
          else
            render json: { error: "Password and confirmation do not match" }, status: :unprocessable_entity
          end
        else
          render json: { error: "New password and confirmation are required" }, status: :unprocessable_entity
        end
      else
        render json: { error: "Invalid or expired token" }, status: :unprocessable_entity
      end
    end
    
    private

    def user_params
      params.require(:user).permit(:username, :email, :password, :confirm_password)
    end

    def expired?(token)
      user = User.find_by(reset_password_token: token)
      return false unless user
      user.reset_password_sent_at < 24.hours.ago
    end
end  
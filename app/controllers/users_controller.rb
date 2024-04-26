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
        if @user.password == user[:password]
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
      password_reset = User.find_by(token: params[:token])
      if password_reset && !password_reset.expired?
        user = password_reset.user
        if user.update(password: params[:password], password_confirmation: params[:password_confirmation])
          password_reset.destroy
          render json: { message: "Password successfully updated" }
        else
          render json: { errors: user.errors.full_messages }, status: :unprocessable_entity
        end
      else
        render json: { error: "Invalid or expired token" }, status: :unprocessable_entity
      end
    end

  
    private

    def user_params
      params.require(:user).permit(:username, :email, :password, :confirm_password)
    end
  end  
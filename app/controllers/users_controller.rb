class UsersController < ApplicationController
  def signup
    @user = User.new(user_params)
    if @user.save
      render_success(@user)
    else
      render_error(@user.errors.full_messages.join(', '))
    end
  end
  
  def login
    user = user_params
    @user = User.find_by(username: user[:username])
    if @user.nil?
      render_error("Username not found")
    elsif user[:password].blank?
      render_error("Password can't be blank")
    else
      begin
        if @user.password == user[:password]
          token = encode_data({ user_data: @user.id })
          render_success({ user: user, token: token })
        else
          render_error("Invalid credentials")
        end
      rescue => e
        render_error("An error occurred: #{e.message}")
      end
    end
  end

  def forgot_password
    email_param = params[:email]
    @user = User.find_by(email: email_param)
    if @user.present?
      @user.generate_password_token!
      UserMailer.password_reset_email(@user).deliver_now
      render_success("Password reset instructions sent successfully")
    else
      render_error("User not found with email")
    end
  end

  def reset_password
    token = params[:token]
    user = User.find_by(reset_password_token: token)
    if user && !expired?(token)
      if params[:new_password].present? && params[:password_confirmation].present?
        if params[:new_password] == params[:password_confirmation]
          if user.update(password: params[:new_password], reset_password_token: nil)
            render_success("Password successfully updated")
          else
            render_error(user.errors.full_messages.join(', '))
          end
        else
          render_error("Password and confirmation do not match")
        end
      else
        render_error("New password and confirmation are required")
      end
    else
      render_error("Invalid or expired token")
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

  def render_success(data)
    render json: {data: data}
  end

  def render_error(message, status = :unprocessable_entity)
    render json: { error: message }, status: status
  end
end

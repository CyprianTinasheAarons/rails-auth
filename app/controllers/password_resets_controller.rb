class PasswordResetsController < ApplicationController
    def new; end
    def edit
      # finds user with a valid token
      @user = User.find_signed!(params[:token], purpose: 'password_reset')
      rescue ActiveSupport::MessageVerifier::InvalidSignature
        redirect_to sign_in_path, alert: 'Your token has expired. Please try again.'
    end
    def update
      # updates user's password
      @user = User.find_signed!(params[:token], purpose: 'password_reset')
      if @user.update(password_params)
        redirect_to sign_in_path, notice: 'Your password was reset successfully. Please sign in'
        else
        render :edit
      end
    end
    def create
      # finds user by email
      @user = User.find_by(email: params[:email])
      # sends email to user with password reset link
      if @user.present?
        PasswordMailer.with(user: @user).reset.deliver_later
      end
      redirect_to root_path, notice: 'Email sent with password reset instructions.'
    end
  
    private
    def password_params
      params.require(:user).permit(:password, :password_confirmation)
    end
  end

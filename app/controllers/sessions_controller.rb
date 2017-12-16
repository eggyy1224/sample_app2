class SessionsController < ApplicationController
  def new
  end

  def create
    @user = User.find_by(email: params[:session][:email].downcase)#此處的session為params的其中一個key
    
    if @user && @user.authenticate(params[:session][:password])
      if @user.activated?
        log_in @user#將session[:user_id]設定為user.id
        params[:session][:remember_me] == '1' ? remember(@user) : forget(@user) 
        redirect_back_or @user#=user_path(user)
      else
        message  = "Account not activated. "
        message += "Check your email for the activation link."
        flash[:warning] = message
        redirect_to root_url
      end
      
    else
      flash.now[:danger] = 'Invalid email/password combination'
      render :new
    end
  end

  def destroy
    log_out if logged_in?#只有登入的時候才能夠登出
    redirect_to root_url
  end
end

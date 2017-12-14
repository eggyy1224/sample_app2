class SessionsController < ApplicationController
  def new
  end

  def create
    user = User.find_by(email: params[:session][:email].downcase)#此處的session為params的其中一個key
    
    if user && user.authenticate(params[:session][:password])
      log_in user#將session[:user_id]設定為user.id
      redirect_to user#=user_path(user)
    else
      flash.now[:danger] = 'Invalid email/password combination'
      render :new
    end
  end

  def destroy
    log_out
    redirect_to root_url
  end
end

module SessionsHelper
  def log_in(user)
    session[:user_id] = user.id#將session的user_id key指派為user.id
  end

  def current_user
    @current_user ||= User.find_by(id: session[:user_id])#find_by找不到值會回傳nil,find則會回傳錯誤
  end

  def logged_in?#is there current_user?
    !current_user.nil?
  end

  def log_out
    session.delete(:user_id)
    current_user = nil
  end
end

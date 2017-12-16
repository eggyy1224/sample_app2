module SessionsHelper
  def log_in(user)
    session[:user_id] = user.id#將session的user_id key指派為user.id
  end

  def remember(user)#和User裡的類別方法不一樣
    user.remember#調用類別方法，創造令牌與摘要並存進remember_digest中
    cookies.permanent.signed[:user_id] = user.id#將目前的user_id以及記憶摘要存進瀏覽器的cookies中
    cookies.permanent[:remember_token] = user.remember_token
  end

  # 返回 cookie 中记忆令牌对应的用户
  def current_user
    if (user_id = session[:user_id])#如果session裡面有user_id的話便把值給user_id這個變數
      @current_user ||= User.find_by(id: user_id) #find_by如果找不到會回傳nil,find則會回傳錯誤
    elsif (user_id = cookies.signed[:user_id])#如果cookies裡面有user_id的話便把值給user_id這個變數
      user = User.find_by(id: user_id)
      if user && user.authenticated?(:remember,cookies[:remember_token])#如果cookies裡面的令牌資訊跟資料庫裡的摘要是一致的話
        log_in user#就登入這個使用者
        @current_user = user#並且把current_user設定為現在的user
      end
    end
      
  end

  def logged_in?#is there current_user?
    !current_user.nil?
  end
   #忘記持久session
  def forget(user)
    user.forget#先呼叫實例方法
    cookies.delete(:user_id)#再刪除cookie
    cookies.delete(:remember_token)
  end

  def log_out
    forget(current_user)#登出時呼叫forget方法，將remember_token清除
    session.delete(:user_id)
    current_user = nil
  end

  def current_user?(user)
    user == current_user 
  end

  #重定向到儲存的地址或者默認的地址
  def redirect_back_or(default)
    redirect_to(session[:forwarding_url] || default)
    session.delete(:forwarding_url)
  end

  #儲存後面需要用到的地址
  def store_location
    session[:forwarding_url] = request.original_url if request.get?
  end

 
end

class ApplicationController < ActionController::Base
  protect_from_forgery with: :exception
  include SessionsHelper#introduce helper methods to all controllers

  private
    def logged_in_user
      unless logged_in?
        store_location#未登入的話先把地址儲存下來
        flash[:danger] = "Please log in"
        redirect_to login_url
      end
    end
end

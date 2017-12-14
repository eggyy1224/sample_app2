require File.expand_path('../../config/environment', __FILE__)
require 'rails/test_help'
require "minitest/reporters"
Minitest::Reporters.use! 

class ActiveSupport::TestCase
  # Setup all fixtures in test/fixtures/*.yml for all tests in alphabetical order.
  fixtures :all

  # Add more helper methods to be used by all tests here...
  # 如果用户已登录，返回 true
  def is_logged_in?
    !session[:user_id].nil?
  end

  def log_in_as(user)
    session[:user_id] = user.id 
  end
  include ApplicationHelper
end

class ActionDispatch::IntegrationTest

  # 登入指定的用户
  def log_in_as(user, password: 'password', remember_me: '1')#因為類別繼承的不同所以才要分別放兩個地方？
    post login_path, params: { session: { email: user.email,
                                          password: password,
                                          remember_me: remember_me } }
  end
end

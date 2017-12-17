require 'test_helper'

class PasswordResetsTest < ActionDispatch::IntegrationTest
  def setup
    ActionMailer::Base.deliveries.clear
    @user = users(:michael)
  end

  test "reset password test" do
    get new_password_reset_path
    assert_template 'password_resets/new'
    #電子郵件無效
    post password_resets_path, params: { password_reset: { email: "" } }
    assert_not flash.empty?
    assert_template 'password_resets/new'
    #電子郵件有效
    post password_resets_path, params: { password_reset: { email: @user.email } }
    assert_not_equal @user.reset_digest, @user.reload.reset_digest
    assert_equal 1, ActionMailer::Base.deliveries.size
    assert_not flash.empty?
    assert_redirected_to root_url
    #密碼重設表單
    user = assigns(:user)
    #電子郵件地址錯誤，點擊activation link
    get edit_password_reset_path(user.reset_token, email: "")
    assert_redirected_to root_url
    #用戶未激活
    user.toggle!(:activated)
    get edit_password_reset_path(user.reset_token, email: user.email)
    assert_redirected_to root_url
    user.toggle!(:activated)
    #valid email with invalid reset token
    get edit_password_reset_path("invalid token", email: user.email)
    assert_redirected_to root_url
    #valid email and reset token
    get edit_password_reset_path(user.reset_token, email: user.email)
    assert_template 'password_resets/edit'
    assert_select "input[name=email][type=hidden][value=?]", user.email#傳給update的隱藏屬性
    # 密码和密码确认不匹配
    patch password_reset_path(user.reset_token),
          params: { email: user.email,
                    user: { password:              "foobaz",
                            password_confirmation: "barquux" } }
    assert_select 'div#error_explanation'
    #empty password
    patch password_reset_path(user.reset_token),
          params: { email: user.email,
                    user: { password:              "",
                            password_confirmation: "" } }
    assert_select 'div#error_explanation'
    #valid reset password
    patch password_reset_path(user.reset_token),
          params: { email: user.email,
                    user: { password:              "foobar",
                            password_confirmation: "foobar" } }
    assert is_logged_in?
    assert_equal nil, user.reload.reset_digest
    assert_not flash.empty?
    assert_redirected_to user
  end

  test "expired_token" do
    get new_password_reset_path
    post password_resets_path,
         params: { password_reset: { email: @user.email } }

    @user = assigns(:user)
    @user.update_attribute(:reset_sent_at, 3.hours.ago)
    patch password_reset_path(@user.reset_token),
          params: { email: @user.email,
                    user: { password:              "foobar",
                            password_confirmation: "foobar" } }
    assert_response :redirect
    follow_redirect!
    assert_match /expired/i, response.body
  end

end

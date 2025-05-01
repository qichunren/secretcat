require "test_helper"

class I18nTest < ActionDispatch::IntegrationTest
  test "default language should be English" do
    # 验证当前语言设置
    assert_equal :en, I18n.locale

    # 访问首页并验证英文内容
    get root_path
    assert_response :success
    assert_select "h1", text: "Securely Manage Your Passwords"  # 英文标语
    assert_select "a.text-slate-300", text: "How it works"     # 英文导航链接

    # 访问注册页面并验证英文内容
    get signup_path
    assert_response :success
    assert_select "h2", text: "Create Your Account"            # 英文标题
    assert_select "label", text: "Master Password"             # 英文表单标签
  end

  test "should still be able to switch language" do
    original_locale = I18n.default_locale
    begin
      # 临时改变默认语言为中文
      I18n.default_locale = :zh
      get root_path
      assert_response :success
      assert_select "h1", text: "安全地管理您的密码"           # 中文标语

      # 切换回英文
      I18n.default_locale = :en
      get root_path
      assert_response :success
      assert_select "h1", text: "Securely Manage Your Passwords" # 确认恢复为英文
    ensure
      # 确保测试结束后恢复原始设置
      I18n.default_locale = original_locale
    end
  end
end

require "test_helper"

class SessionsControllerTest < ActionDispatch::IntegrationTest
  def setup
    @user = User.new(email: "test@example.com")
    @user.set_master_password("password123")
    @user.save!
  end

  test "should get new" do
    get login_url
    assert_response :success
  end

  test "should handle create request" do
    post login_url, params: { email: "test@example.com", master_password: "password123" }
    assert_response :redirect
    assert_redirected_to password_entries_path
  end

  test "should handle destroy request" do
    delete logout_url
    assert_response :redirect
    assert_redirected_to root_path
  end
end

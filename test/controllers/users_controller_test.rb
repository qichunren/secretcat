require "test_helper"

class UsersControllerTest < ActionDispatch::IntegrationTest
  test "should get new" do
    get signup_url
    assert_response :success
  end

  test "should create user" do
    assert_difference("User.count") do
      post users_url, params: {
        user: {
          email: "test@example.com",
          master_password: "password123"
        }
      }
    end
    assert_response :redirect
    assert_redirected_to password_entries_path
  end
end

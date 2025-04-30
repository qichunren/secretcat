require "test_helper"

class PasswordEntriesControllerTest < ActionDispatch::IntegrationTest
  test "should get create" do
    get password_entries_create_url
    assert_response :success
  end

  test "should get show" do
    get password_entries_show_url
    assert_response :success
  end
end

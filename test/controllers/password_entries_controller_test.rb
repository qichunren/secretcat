require "test_helper"

class PasswordEntriesControllerTest < ActionDispatch::IntegrationTest
  def setup
    @user = User.new(email: "test@example.com")
    @key = @user.set_master_password("password123")
    @user.save!
    post login_url, params: { email: "test@example.com", master_password: "password123" }
  end

  test "should get index" do
    get password_entries_url
    assert_response :success
  end

  test "should get new" do
    get new_password_entry_url
    assert_response :success
  end

  test "should create password_entry" do
    assert_difference("PasswordEntry.count") do
      post password_entries_url, params: {
        password_entry: {
          name: "Test Entry",
          url: "https://example.com",
          username: "testuser",
          password: "password123"
        }
      }
    end
    assert_redirected_to password_entries_path
  end

  test "should show password_entry" do
    entry = @user.password_entries.create!(
      name: "Test Entry",
      encrypted_data: PasswordEntry.encrypt_data(
        {
          url: "https://example.com",
          username: "testuser",
          password: "password123"
        },
        @key
      )
    )
    get password_entry_url(entry)
    assert_response :success
  end
end

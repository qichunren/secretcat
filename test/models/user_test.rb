require "test_helper"

class UserTest < ActiveSupport::TestCase
  def setup
    @user = User.new(email: "test@example.com")
    @master_password = "very_secure_password_123"
  end

  test "should be valid with valid attributes" do
    @user.set_master_password(@master_password)
    assert @user.valid?
  end

  test "should require email" do
    @user.email = nil
    @user.set_master_password(@master_password)
    assert_not @user.valid?
    assert_includes @user.errors[:email], "can't be blank"
  end

  test "should require unique email" do
    @user.set_master_password(@master_password)
    @user.save!

    duplicate_user = User.new(email: @user.email)
    duplicate_user.set_master_password(@master_password)
    assert_not duplicate_user.valid?
    assert_includes duplicate_user.errors[:email], "has already been taken"
  end

  test "should set password hash and salt when setting master password" do
    key = @user.set_master_password(@master_password)

    assert_not_nil @user.password_hash
    assert_not_nil @user.salt
    assert_equal 32, key.bytesize # 256 bits = 32 bytes
  end

  test "should authenticate with correct master password" do
    @user.set_master_password(@master_password)
    assert @user.authenticate(@master_password)
  end

  test "should not authenticate with incorrect master password" do
    @user.set_master_password(@master_password)
    assert_not @user.authenticate("wrong_password")
  end

  test "should generate different salt for different users" do
    user1 = User.new(email: "user1@example.com")
    user2 = User.new(email: "user2@example.com")

    user1.set_master_password(@master_password)
    user2.set_master_password(@master_password)

    assert_not_equal user1.salt, user2.salt
  end

  test "should generate different password hash for same password with different salt" do
    user1 = User.new(email: "user1@example.com")
    user2 = User.new(email: "user2@example.com")

    user1.set_master_password(@master_password)
    user2.set_master_password(@master_password)

    assert_not_equal user1.password_hash, user2.password_hash
  end

  test "should destroy associated password entries when user is destroyed" do
    @user.set_master_password(@master_password)
    @user.save!

    @user.password_entries.create!(
      name: "Test Entry",
      encrypted_data: "encrypted_test_data"
    )

    assert_difference "PasswordEntry.count", -1 do
      @user.destroy
    end
  end
end

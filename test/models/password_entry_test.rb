require "test_helper"

class PasswordEntryTest < ActiveSupport::TestCase
  def setup
    @user = User.new(email: "test@example.com")
    @master_password = "very_secure_password_123"
    @key = @user.set_master_password(@master_password)
    @user.save!

    @password_entry = @user.password_entries.build(
      name: "Test Entry",
      encrypted_data: PasswordEntry.encrypt_data(
        {
          "url" => "https://example.com",
          "username" => "testuser",
          "password" => "password123"
        },
        @key
      )
    )
  end

  test "should be valid with valid attributes" do
    assert @password_entry.valid?
  end

  test "should require name" do
    @password_entry.name = nil
    assert_not @password_entry.valid?
    assert_includes @password_entry.errors[:name], "can't be blank"
  end

  test "should require encrypted_data" do
    @password_entry.encrypted_data = nil
    assert_not @password_entry.valid?
    assert_includes @password_entry.errors[:encrypted_data], "can't be blank"
  end

  test "should require user" do
    @password_entry.user = nil
    assert_not @password_entry.valid?
    assert_includes @password_entry.errors[:user], "must exist"
  end

  test "should encrypt and decrypt data correctly" do
    original_data = {
      "url" => "https://example.com",
      "username" => "testuser",
      "password" => "password123"
    }

    # 测试加密
    encrypted = PasswordEntry.encrypt_data(original_data, @key)
    assert_not_equal original_data.to_json, encrypted

    # 测试解密
    entry = PasswordEntry.new(encrypted_data: encrypted)
    decrypted_data = entry.decrypt_data(@key)

    assert_equal original_data["url"], decrypted_data["url"]
    assert_equal original_data["username"], decrypted_data["username"]
    assert_equal original_data["password"], decrypted_data["password"]
  end

  test "should handle complex data types in encryption" do
    complex_data = {
      "urls" => ["https://example1.com", "https://example2.com"],
      "credentials" => {
        "primary" => { "username" => "user1", "password" => "pass1" },
        "secondary" => { "username" => "user2", "password" => "pass2" }
      },
      "tags" => ["work", "personal"],
      "last_used" => Time.current.to_s,
      "access_count" => 42
    }

    encrypted = PasswordEntry.encrypt_data(complex_data, @key)
    entry = PasswordEntry.new(encrypted_data: encrypted)
    decrypted_data = entry.decrypt_data(@key)

    assert_equal complex_data["urls"], decrypted_data["urls"]
    assert_equal complex_data["credentials"], decrypted_data["credentials"]
    assert_equal complex_data["tags"], decrypted_data["tags"]
    assert_equal complex_data["access_count"], decrypted_data["access_count"]
  end

  test "should raise error when decrypting with wrong key" do
    wrong_key = SecureRandom.random_bytes(32)

    assert_raises(StandardError) do
      @password_entry.decrypt_data(wrong_key)
    end
  end

  test "should generate different ciphertexts for same data" do
    data = { "username" => "test", "password" => "secret" }

    encrypted1 = PasswordEntry.encrypt_data(data, @key)
    encrypted2 = PasswordEntry.encrypt_data(data, @key)

    # 相同的数据每次加密应该产生不同的密文（因为使用了随机IV）
    assert_not_equal encrypted1, encrypted2
  end

  test "should handle empty data structures" do
    empty_data = { "urls" => [], "credentials" => {}, "tags" => [] }

    encrypted = PasswordEntry.encrypt_data(empty_data, @key)
    entry = PasswordEntry.new(encrypted_data: encrypted)
    decrypted_data = entry.decrypt_data(@key)

    assert_equal empty_data["urls"], decrypted_data["urls"]
    assert_equal empty_data["credentials"], decrypted_data["credentials"]
    assert_equal empty_data["tags"], decrypted_data["tags"]
  end

  test "should handle special characters in data" do
    special_data = {
      "url" => "https://例子.com/path?query=值",
      "username" => "user@例子.com",
      "password" => "p@ssw0rd!@#$%^&*()_+"
    }

    encrypted = PasswordEntry.encrypt_data(special_data, @key)
    entry = PasswordEntry.new(encrypted_data: encrypted)
    decrypted_data = entry.decrypt_data(@key)

    assert_equal special_data["url"], decrypted_data["url"]
    assert_equal special_data["username"], decrypted_data["username"]
    assert_equal special_data["password"], decrypted_data["password"]
  end

  test "should handle large data structures" do
    large_data = {
      "urls" => Array.new(100) { |i| "https://example#{i}.com" },
      "notes" => "a" * 10000, # 10KB的文本
      "tags" => Array.new(1000) { |i| "tag#{i}" }
    }

    encrypted = PasswordEntry.encrypt_data(large_data, @key)
    entry = PasswordEntry.new(encrypted_data: encrypted)
    decrypted_data = entry.decrypt_data(@key)

    assert_equal large_data["urls"], decrypted_data["urls"]
    assert_equal large_data["notes"], decrypted_data["notes"]
    assert_equal large_data["tags"], decrypted_data["tags"]
  end
end

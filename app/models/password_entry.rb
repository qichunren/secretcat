class PasswordEntry < ApplicationRecord
  belongs_to :user
  validates :name, :encrypted_data, presence: true

  # 加密数据
  def self.encrypt_data(data, key)
    encryptor = ActiveSupport::MessageEncryptor.new(key)
    encryptor.encrypt_and_sign(data.to_json)
  end

  # 解密数据
  def decrypt_data(key)
    encryptor = ActiveSupport::MessageEncryptor.new(key)
    JSON.parse(encryptor.decrypt_and_verify(encrypted_data))
  rescue ActiveSupport::MessageEncryptor::InvalidMessage
    raise 'Invalid key or corrupted data'
  end
end

require 'openssl'
require 'base64'

class User < ApplicationRecord
  has_many :password_entries, dependent: :destroy

  validates :email, presence: true, uniqueness: true
  validates :password_hash, presence: true
  validates :salt, presence: true

  # 派生密钥并存储密码哈希
  def set_master_password(master_password)
    # 生成随机盐
    self.salt = SecureRandom.random_bytes(16)

    # 使用 PBKDF2 派生密钥（256 位）
    key = OpenSSL::PKCS5.pbkdf2_hmac(
      master_password,
      salt,
      100_000, # 迭代次数，增加计算成本
      32,      # 密钥长度（256 位）
      'sha256' # 哈希算法
    )

    # 存储主密码的哈希（用于验证）
    self.password_hash = Base64.encode64(OpenSSL::HMAC.digest('sha256', key, master_password))

    # 返回派生密钥（用于加密）
    key
  end

  # 验证主密码
  def authenticate(master_password)
    key = OpenSSL::PKCS5.pbkdf2_hmac(
      master_password,
      salt,
      100_000,
      32,
      'sha256'
    )
    Base64.encode64(OpenSSL::HMAC.digest('sha256', key, master_password)) == password_hash
  end
end

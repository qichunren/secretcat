实现一个安全的密码存储服务（如Bitwarden）需要重点关注密码的安全存储、密钥派生和加密机制。以下是用最新版 Ruby on Rails（截至 2025 年 4 月，假设为 Rails 7.x）实现的核心方案，聚焦于密码存储和密钥派生，不依赖外部 gem（如 Devise）。我会尽量简洁并提供代码示例，假设你熟悉 Rails 基础。
核心设计目标
安全存储：用户主密码永不直接存储，使用密钥派生函数生成加密密钥。
密钥派生：使用安全的密钥派生函数（如 Argon2 或 PBKDF2）生成强密钥。
加密：用派生密钥加密敏感数据（如存储的密码条目）。
不依赖外部 gem：使用 Ruby 标准库或 Rails 内置工具。
1. 密钥派生与主密码处理
用户的主密码（master password）通过密钥派生函数（KDF）生成加密密钥。推荐使用 Argon2（内存硬，抗 GPU 攻击），但 Ruby 标准库不支持 Argon2，因此我们使用 Rails 内置的 ActiveSupport::KeyGenerator 和 ActiveSupport::MessageEncryptor，结合 PBKDF2（基于 OpenSSL）。
密钥派生流程
用户输入主密码。
使用 PBKDF2（或其他 KDF）从主密码派生固定长度的加密密钥。
用派生密钥加密存储的密码条目。
存储主密码的哈希（用于验证），但不存储明文主密码。
实现代码
ruby
# app/models/user.rb
require 'openssl'
require 'base64'

class User < ApplicationRecord
  validates :email, presence: true, uniqueness: true
  validates :password_hash, presence: true

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
数据库迁移
ruby
# db/migrate/2025043001_create_users.rb
class CreateUsers < ActiveRecord::Migration[7.0]
  def change
    create_table :users do |t|
      t.string :email, null: false, index: { unique: true }
      t.binary :password_hash, null: false
      t.binary :salt, null: false
      t.timestamps
    end
  end
end
2. 密码条目存储
密码条目（password entries）存储用户保存的网站密码，每个条目使用用户的主密码派生密钥进行加密。Rails 的 ActiveSupport::MessageEncryptor 提供 AES-256-GCM 加密，适合此场景。
模型设计
ruby
# app/models/password_entry.rb
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
数据库迁移
ruby
# db/migrate/2025043002_create_password_entries.rb
class CreatePasswordEntries < ActiveRecord::Migration[7.0]
  def change
    create_table :password_entries do |t|
      t.references :user, null: false, foreign_key: true
      t.string :name, null: false # 条目名称（如 "GitHub"）
      t.text :encrypted_data, null: false # 加密后的数据
      t.timestamps
    end
  end
end
3. 控制器逻辑
以下是用户注册、密码条目创建和解密的控制器逻辑。
ruby
# app/controllers/users_controller.rb
class UsersController < ApplicationController
  def create
    @user = User.new(email: params[:email])
    key = @user.set_master_password(params[:master_password])
    if @user.save
      session[:user_id] = @user.id
      session[:key] = Base64.encode64(key) # 临时存储密钥（生产环境中需更安全）
      render json: { message: 'User created' }, status: :created
    else
      render json: { errors: @user.errors.full_messages }, status: :unprocessable_entity
    end
  end
end

# app/controllers/password_entries_controller.rb
class PasswordEntriesController < ApplicationController
  before_action :authenticate_user

  def create
    entry = current_user.password_entries.build(name: params[:name])
    data = { url: params[:url], username: params[:username], password: params[:password] }
    entry.encrypted_data = PasswordEntry.encrypt_data(data, current_key)
    if entry.save
      render json: { message: 'Password entry created' }, status: :created
    else
      render json: { errors: entry.errors.full_messages }, status: :unprocessable_entity
    end
  end

  def show
    entry = current_user.password_entries.find(params[:id])
    data = entry.decrypt_data(current_key)
    render json: data
  rescue StandardError => e
    render json: { error: e.message }, status: :unprocessable_entity
  end

  private

  def authenticate_user
    @current_user = User.find_by(id: session[:user_id])
    render json: { error: 'Unauthorized' }, status: :unauthorized unless @current_user
  end

  def current_key
    Base64.decode64(session[:key])
  end
end
4. 安全注意事项
密钥管理：
派生密钥（key）在示例中存储在 session 中，仅为演示。生产环境中，应在用户登录时重新派生密钥，且不持久化存储。
使用安全的 session 存储（如 Redis），并确保 HTTPS 传输。
盐和哈希：
每个用户使用随机盐（salt），防止彩虹表攻击。
密码哈希使用 HMAC-SHA256，确保验证安全。
加密：
ActiveSupport::MessageEncryptor 使用 AES-256-GCM，提供认证加密，防止篡改。
确保数据库只存储加密后的数据（encrypted_data）。
KDF 参数：
PBKDF2 的迭代次数（100,000）应根据服务器性能调整，目标是每次派生耗时 ~0.1-0.5 秒。
如果需要更高安全性，可引入 argon2 gem（违背无外部 gem 要求）。
其他：
实现密码重置机制时，避免泄露主密码或派生密钥。
对 API 端点实施速率限制，防止暴力破解。
定期审计代码，检查潜在漏洞。
5. 扩展建议
前端：使用 JavaScript（如 Web Crypto API）在客户端加密敏感数据，进一步减少服务器端明文风险。
备份：支持加密导出密码条目，存储为用户可下载的加密文件。
多因子认证：添加 TOTP（如 Google Authenticator）支持，增强登录安全。
性能：缓存派生密钥（短期，加密存储），减少重复计算。
示例 API 调用
注册用户：
bash
curl -X POST -d "email=user@example.com&master_password=strongpassword" http://localhost:3000/users
创建密码条目：
bash
curl -X POST -d "name=GitHub&url=https://github.com&username=user&password=secret" http://localhost:3000/password_entries
获取密码条目：
bash
curl http://localhost:3000/password_entries/1
总结
以上方案使用 Rails 内置工具实现了安全的密码存储服务：
密钥派生：通过 PBKDF2 从主密码生成加密密钥。
存储：主密码哈希和盐存储在用户表，密码条目以加密形式存储。
加密：使用 AES-256-GCM 确保数据机密性和完整性。
如果需要更详细的某部分实现（例如前端集成或 TOTP），或有其他具体要求，请告诉我！
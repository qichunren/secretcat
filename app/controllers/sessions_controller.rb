class SessionsController < ApplicationController
  def new
  end

  def create
    user = User.find_by(email: params[:email])
    if user&.authenticate(params[:master_password])
      key = OpenSSL::PKCS5.pbkdf2_hmac(
        params[:master_password],
        user.salt,
        100_000,
        32,
        'sha256'
      )
      session[:user_id] = user.id
      session[:key] = Base64.encode64(key)
      redirect_to password_entries_path, notice: '登录成功'
    else
      flash.now[:alert] = '邮箱或密码错误'
      render :new, status: :unprocessable_entity
    end
  end

  def destroy
    session.delete(:user_id)
    session.delete(:key)
    redirect_to root_path, notice: '已安全退出'
  end
end

class UsersController < ApplicationController
  def create
    @user = User.new(email: params[:email])
    key = @user.set_master_password(params[:master_password])

    if @user.save
      session[:user_id] = @user.id
      session[:key] = Base64.encode64(key) # 临时存储密钥（生产环境中需更安全）
      render json: { message: 'User created successfully' }, status: :created
    else
      render json: { errors: @user.errors.full_messages }, status: :unprocessable_entity
    end
  end

  private

  def user_params
    params.require(:user).permit(:email, :master_password)
  end
end

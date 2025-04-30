class UsersController < ApplicationController
  def new
    @user = User.new
  end

  def create
    @user = User.new(email: params[:user][:email])
    key = @user.set_master_password(params[:user][:master_password])

    if @user.save
      session[:user_id] = @user.id
      session[:key] = Base64.encode64(key)
      redirect_to password_entries_path, notice: '账号创建成功'
    else
      render :new, status: :unprocessable_entity
    end
  end

  private

  def user_params
    params.require(:user).permit(:email, :master_password)
  end
end

class PasswordEntriesController < ApplicationController
  before_action :authenticate_user
  before_action :set_password_entry, only: [:show, :edit, :update, :destroy]

  def index
    @password_entries = current_user.password_entries
  end

  def show
  end

  def new
    @password_entry = current_user.password_entries.build
  end

  def create
    @password_entry = current_user.password_entries.build(name: params[:password_entry][:name])
    data = {
      url: params[:password_entry][:url],
      username: params[:password_entry][:username],
      password: params[:password_entry][:password]
    }
    @password_entry.encrypted_data = PasswordEntry.encrypt_data(data, current_key)

    if @password_entry.save
      redirect_to password_entries_path, notice: '密码已成功保存'
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
  end

  def update
    data = {
      url: params[:password_entry][:url],
      username: params[:password_entry][:username],
      password: params[:password_entry][:password]
    }
    @password_entry.name = params[:password_entry][:name]
    @password_entry.encrypted_data = PasswordEntry.encrypt_data(data, current_key)

    if @password_entry.save
      redirect_to password_entries_path, notice: '密码已成功更新'
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @password_entry.destroy
    redirect_to password_entries_path, notice: '密码已成功删除'
  end

  private

  def authenticate_user
    @current_user = User.find_by(id: session[:user_id])
    redirect_to login_path, alert: '请先登录' unless @current_user
  end

  def set_password_entry
    @password_entry = current_user.password_entries.find(params[:id])
  rescue ActiveRecord::RecordNotFound
    redirect_to password_entries_path, alert: '未找到该密码条目'
  end

  def current_user
    @current_user
  end

  def current_key
    Base64.decode64(session[:key])
  end
end

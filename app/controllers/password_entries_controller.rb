class PasswordEntriesController < ApplicationController
  before_action :authenticate_user

  def create
    entry = current_user.password_entries.build(name: params[:name])
    data = { url: params[:url], username: params[:username], password: params[:password] }
    entry.encrypted_data = PasswordEntry.encrypt_data(data, current_key)

    if entry.save
      render json: { message: 'Password entry created successfully' }, status: :created
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

  def current_user
    @current_user
  end

  def current_key
    Base64.decode64(session[:key])
  end
end

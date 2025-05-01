class ApplicationController < ActionController::Base
  # Only allow modern browsers supporting webp images, web push, badges, import maps, CSS nesting, and CSS :has.
  allow_browser versions: :modern

  helper_method :current_user, :current_key

  before_action :set_locale

  private

  def current_user
    @current_user ||= User.find_by(id: session[:user_id]) if session[:user_id]
  end

  def current_key
    Base64.decode64(session[:key]) if session[:key]
  end

  def authenticate_user!
    unless current_user
      redirect_to login_path, alert: "请先登录"
    end
  end

  def set_locale
    I18n.locale = cookies[:locale] || I18n.default_locale
  end
end

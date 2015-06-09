# -*- encoding : utf-8 -*-
class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception

  before_action :require_login, :set_language, :user_picture, :ensure_signup_complete

  def user_picture
    return unless current_user
    @thumbnail_picture = @current_user.profile_image.expiring_url(3600, :thumb)
    # @user_picture = AmazonS3.instance.get_url('profile_picture_default.png')
  end

  def after_sign_in_path_for(resource)
    sign_in_url = new_user_session_url
    if session[:user_original_url] == sign_in_url
      super
    else
      stored_location_for(resource) || session[:user_original_url] || dashboard_path
    end
  end

  def ensure_signup_complete
    # Ensure we don't go into an infinite loop
    return if action_name == 'finish_signup'

    # Redirect to the 'finish_signup' page if the user
    # email, first name or last name hasn't been saved
    return unless current_user && (UserEmail.find_by(user: current_user, is_primary: true).autogenerated? || current_user.first_name_autogenerated? || current_user.last_name_autogenerated?)
    session_infos = {}
    session_infos[:first_name] = current_user.first_name unless current_user.first_name_autogenerated?
    session_infos[:last_name] = current_user.last_name unless current_user.last_name_autogenerated?
    session_infos[:primary_email] = current_user.primary_email unless UserEmail.find_by(user: current_user).autogenerated?
    session[:resource] = session_infos
    redirect_to finish_signup_path
  end

  private

  def set_language
    locale = http_accept_language.compatible_language_from(I18n.available_locales)
    if session[:language] && I18n.available_locales.include?(session[:language].to_sym)
      locale = session[:language]
    end
    if params[:language] && I18n.available_locales.include?(params[:language].to_sym)
      locale = params[:language]
      session[:language] = locale
    end
    I18n.locale = locale
  end

  def require_login
    return if user_signed_in?
    flash[:error] = t('flash.error.login.reqired')
    session[:user_original_url] = request.fullpath
    redirect_to new_user_session_path # halts request cycle
  end

  def language_names
    {de: 'Deutsch', en: 'English'}
  end
  helper_method 'language_names'
end

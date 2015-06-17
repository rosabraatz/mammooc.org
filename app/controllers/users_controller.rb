# -*- encoding : utf-8 -*-
class UsersController < ApplicationController
  include ConnectorMapper
  before_action :set_provider_logos, only: [:settings, :mooc_provider_settings]
  load_and_authorize_resource only: [:show, :edit, :update, :destroy, :finish_signup]

  rescue_from CanCan::AccessDenied do |exception|
    respond_to do |format|
      format.html { redirect_to root_path, alert: t("unauthorized.#{exception.action}.user") }
      format.json do
        error = {message: exception.message, action: exception.action, subject: exception.subject.id}
        render json: error.to_json, status: :unauthorized
      end
    end
  end

  # GET /users/1
  # GET /users/1.json
  def show
    @user_picture = current_user.profile_image.expiring_url(3600, :square)
  end

  # GET /users/1/edit
  def edit
  end

  # PATCH/PUT /users/1
  # PATCH/PUT /users/1.json
  def update
    respond_to do |format|
      if @user.update(user_params)
        format.html { redirect_to @user, notice: t('flash.notice.users.successfully_updated') }
        format.json { render :show, status: :ok, location: @user }
      else
        format.html { render :edit }
        format.json { render json: @user.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /users/1
  # DELETE /users/1.json
  def destroy
    unless UserGroup.find_by_user_id(@user.id).blank?
      UserGroup.find_by_user_id(@user.id).destroy
    end
    @user.destroy
    respond_to do |format|
      format.html { redirect_to users_url, notice: t('flash.notice.users.successfully_destroyed') }
      format.json { head :no_content }
    end
  end

  def synchronize_courses
    @synchronization_state = {}
    @synchronization_state[:open_hpi] = OpenHPIUserWorker.new.perform [current_user.id]
    @synchronization_state[:open_sap] = OpenSAPUserWorker.new.perform [current_user.id]
    if CourseraUserWorker.new.perform [current_user.id]
      @synchronization_state[:coursera] = true
    else
      @synchronization_state[:coursera] = CourseraConnector.new.oauth_link(synchronize_courses_path(current_user), masked_authenticity_token(session))
    end
    @partial = render_to_string partial: 'dashboard/user_courses', formats: [:html]
    respond_to do |format|
      begin
        format.html { redirect_to dashboard_path }
        format.json { render :synchronization_result, status: :ok }
      rescue StandardError => e
        format.html { redirect_to dashboard_path }
        format.json { render json: e.to_json, status: :unprocessable_entity }
      end
    end
  end

  def account_settings
    @partial = render_to_string partial: 'devise/registrations/edit', formats: [:html]
    respond_to do |format|
      begin
        format.html { redirect_to dashboard_path }
        format.json { render :settings, status: :ok }
      rescue StandardError => e
        format.html { redirect_to dashboard_path }
        format.json { render json: e.to_json, status: :unprocessable_entity }
      end
    end
  end

  def mooc_provider_settings
    prepare_mooc_provider_settings

    @partial = render_to_string partial: 'users/mooc_provider_settings', formats: [:html]
    respond_to do |format|
      begin
        format.html { redirect_to dashboard_path }
        format.json { render :settings, status: :ok }
      rescue StandardError => e
        format.html { redirect_to dashboard_path }
        format.json { render json: e.to_json, status: :unprocessable_entity }
      end
    end
  end

  def privacy_settings
    prepare_privacy_settings
    @partial = render_to_string partial: 'users/privacy_settings', formats: [:html]

    respond_to do |format|
      begin
        format.html { redirect_to dashboard_path }
        format.json { render :settings, status: :ok }
      rescue StandardError => e
        format.html { redirect_to dashboard_path }
        format.json { render json: e.to_json, status: :unprocessable_entity }
      end
    end
  end

  def settings
    prepare_mooc_provider_settings
    prepare_privacy_settings
    @subsite = params['subsite']
  end

  def set_setting
    setting = current_user.setting(params[:setting])
    setting.set(params[:key], params[:value])

    respond_to do |format|
      format.json { render json: {status: :ok} }
    end
  end

  def connected_users_autocomplete
    search = params[:q].downcase
    users = current_user.connected_users.select{|u| u.first_name.downcase.include?(search) || u.last_name.downcase.include?(search) }
              .collect { |u| {id: u.id, first_name: u.first_name, last_name: u.last_name, email: u.primary_email} }

    respond_to do |format|
      format.json { render json: users }
    end
  end

  def oauth_callback
    code = params[:code]
    state = params[:state].split(/~/)
    mooc_provider = MoocProvider.find_by_name(state.first)
    destination_path = state.second
    csrf_token = state.third
    flash['error'] ||= []

    return oauth_error_and_redirect(destination_path) if mooc_provider.blank?

    provider_connector = get_connector_by_mooc_provider mooc_provider

    return oauth_error_and_redirect(destination_path) if provider_connector.blank? && mooc_provider.api_support_state != 'oauth'

    if params[:error].present? || !valid_authenticity_token?(session, csrf_token)
      provider_connector.destroy_connection(current_user)
      return oauth_error_and_redirect(destination_path)
    elsif code.present?
      provider_connector.initialize_connection(current_user, code: code)
      redirect_to destination_path
    end
  end

  def oauth_error_and_redirect(destination_path)
    flash['error'] << "#{t('users.synchronization.oauth_error')}"
    redirect_to destination_path
  end

  def set_mooc_provider_connection
    @got_connection = false
    mooc_provider = MoocProvider.find_by_id(params[:mooc_provider])
    if mooc_provider.present?
      provider_connector = get_connector_by_mooc_provider mooc_provider
      if provider_connector.present?
        @got_connection = provider_connector.initialize_connection(
          current_user, email: params[:email], password: params[:password])
        provider_connector.load_user_data([current_user])
      end
    end
    set_provider_logos
    prepare_mooc_provider_settings
    @partial = render_to_string partial: 'users/mooc_provider_settings', formats: [:html]
    respond_to do |format|
      begin
        format.html { redirect_to dashboard_path }
        format.json { render :set_mooc_provider_connection_result, status: :ok }
      rescue StandardError => e
        format.html { redirect_to dashboard_path }
        format.json { render json: e.to_json, status: :unprocessable_entity }
      end
    end
  end

  def revoke_mooc_provider_connection
    @revoked_connection = true
    mooc_provider = MoocProvider.find_by_id(params[:mooc_provider])
    if mooc_provider.present?
      provider_connector = get_connector_by_mooc_provider mooc_provider
      if provider_connector.present?
        @revoked_connection = provider_connector.destroy_connection(current_user)
      end
    end
    set_provider_logos
    prepare_mooc_provider_settings
    @partial = render_to_string partial: 'users/mooc_provider_settings', formats: [:html]
    respond_to do |format|
      begin
        format.html { redirect_to dashboard_path }
        format.json { render :revoke_mooc_provider_connection_result, status: :ok }
      rescue StandardError => e
        format.html { redirect_to dashboard_path }
        format.json { render json: e.to_json, status: :unprocessable_entity }
      end
    end
  end

  private

  def prepare_mooc_provider_settings
    @mooc_providers = MoocProvider.all.map do |mooc_provider|
      provider_connector = get_connector_by_mooc_provider mooc_provider
      if provider_connector.present? && mooc_provider.api_support_state == 'oauth'
        oauth_link = provider_connector.oauth_link("#{user_settings_path(current_user)}?subsite=mooc_provider", masked_authenticity_token(session))
      end
      {id: mooc_provider.id,
       logo_id: mooc_provider.logo_id,
       api_support_state: mooc_provider.api_support_state,
       oauth_link: oauth_link}
    end
    @mooc_provider_connections = current_user.mooc_providers.pluck(:mooc_provider_id)
  end

  def prepare_privacy_settings
    @course_enrollments_visibility_groups = Group.find(current_user.setting(:course_enrollments_visibility).value(:groups) || [])
    @course_enrollments_visibility_users = User.find(current_user.setting(:course_enrollments_visibility).value(:users) || [])

    @course_results_visibility_groups = Group.find(current_user.setting(:course_results_visibility).value(:groups) || [])
    @course_results_visibility_users = User.find(current_user.setting(:course_results_visibility).value(:users) || [])
  end

  def set_provider_logos
    @provider_logos = AmazonS3.instance.all_provider_logos_hash
  end

  # Never trust parameters from the scary internet, only allow the white list through.
  def user_params
    params.require(:user).permit(:first_name, :last_name, :primary_email, :title, :password, :profile_image, :about_me)
  end
end

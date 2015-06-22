# -*- encoding : utf-8 -*-
class CompletionsController < ApplicationController
  # GET /completions
  # GET /completions.json
  def index
    @user = User.find(completions_params[:user_id])
    @completions = Completion.where(user: @user).sort_by(&:created_at).reverse
    courses = []
    @completions.each do |completion|
      courses.push(completion.course)
    end
    @provider_logos = AmazonS3.instance.provider_logos_hash_for_courses(courses)
    @number_of_certificates = []
    @completions.each do |completion|
      @number_of_certificates.push completion.certificates.count
    end
    puts @number_of_certificates
    @verify_available = []
    @completions.each do |completion|
      @verify_available.push completion.certificates.pluck(:verification_url).reject{|element| element.blank?}.present? ? true : false
    end
    puts @verify_available
  end

  private

  # Never trust parameters from the scary internet, only allow the white list through.
  def completions_params
    params.permit(:user_id)
  end
end

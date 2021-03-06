# -*- encoding : utf-8 -*-
class ApiConnectionController < ApplicationController
  def index
  end

  def send_request
    OpenHPICourseWorker.perform_async
    OpenSAPCourseWorker.perform_async
    EdxCourseWorker.perform_async
    CourseraCourseWorker.perform_async
    IversityCourseWorker.perform_async
    redirect_to api_connection_index_path
  end

  def update_user
    UserWorker.perform_async [current_user.id]
    redirect_to api_connection_index_path
  end

  def update_all_users
    UserWorker.perform_async
    redirect_to api_connection_index_path
  end
end

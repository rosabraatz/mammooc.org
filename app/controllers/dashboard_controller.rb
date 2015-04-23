class DashboardController < ApplicationController

  NUMBER_OF_SHOWN_RECOMMENDATIONS = 2

  def dashboard
    all_my_sorted_recommendations = current_user.recommendations.sort_by { |recommendation| recommendation.created_at}.reverse!
    @recommendations = all_my_sorted_recommendations.first(NUMBER_OF_SHOWN_RECOMMENDATIONS)
    @number_of_recommendations = all_my_sorted_recommendations.length
    respond_to do |format|
      format.html {  }
      format.json { render :dashboard, status: :ok }
    end
  end
end


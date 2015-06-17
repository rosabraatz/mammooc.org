# -*- encoding : utf-8 -*-
class Recommendation < ActiveRecord::Base
  belongs_to :author, class_name: 'User'
  belongs_to :course
  belongs_to :group
  has_many :comments
  has_and_belongs_to_many :users
  include PublicActivity::Common

  def self.sorted_recommendations_for_course_and_user(course, user, filter_users = [])
    course_recommendations = []
    recommendations_of_user = user.recommendations

    user.groups.each do |group|
      recommendations_of_user += group.recommendations
    end

    recommendations_of_user.each do |recommendation|
      if recommendation.course == course
        course_recommendations.push(recommendation)
      end
    end

    course_recommendations = self.filter_users(course_recommendations, filter_users)
    course_recommendations.uniq.sort_by(&:created_at).reverse!
  end

  def delete_user_from_recommendation user
    self.users -= [user]
    if self.users.blank? && self.group.blank?
      self.destroy
    end
  end

  def delete_group_recommendation
    self.destroy
  end

  def self.filter_users(recommendations, filter_users)
    recommendations.reject {|r| filter_users.include? r.author }
  end
end

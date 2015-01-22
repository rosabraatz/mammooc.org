class Group < ActiveRecord::Base
  has_many :user_groups
  has_many :users, through: :user_groups, null:false
  has_many :statistics
  has_many :recommendations
  has_many :course_requests
end
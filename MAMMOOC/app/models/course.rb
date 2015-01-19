class Course < ActiveRecord::Base
  belongs_to :mooc_provider
  belongs_to :course_result
  has_many :courses
  has_many :recommendations
  has_many :completions
  has_and_belongs_to_many :users
  has_many :course_requests
  has_many :progresses
end

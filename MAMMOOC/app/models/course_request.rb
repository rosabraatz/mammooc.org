class CourseRequest < ActiveRecord::Base
  belongs_to :course
  belongs_to :user
  belongs_to :group
  belongs_to :approval, null: true
end
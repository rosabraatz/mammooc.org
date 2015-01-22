class User < ActiveRecord::Base
  has_many :emails
  has_many :user_groups
  has_many :groups, through: :user_groups
  has_many :recommendations
  has_and_belongs_to_many :recommendations
  has_many :comments
  has_and_belongs_to_many :mooc_providers
  has_many :completions
  has_and_belongs_to_many :courses
  has_many :course_requests
  has_many :approvals
  has_many :progresses
  has_many :bookmarks
  has_many :evaluations
  has_many :user_assignments
end
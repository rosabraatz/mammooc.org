class ChangeCalculatedRatingInCourses < ActiveRecord::Migration
  def change
    change_column(:courses, :calculated_rating, :float)
  end
end

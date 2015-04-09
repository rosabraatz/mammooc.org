class CreateRecommendationsGroupsJoinTable < ActiveRecord::Migration
  def change
    create_table :groups_recommendations, id: false do |t|
      t.uuid :recommendation_id
      t.uuid :group_id
    end
  end
end

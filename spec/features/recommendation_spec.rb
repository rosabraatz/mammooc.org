require 'rails_helper'

RSpec.describe GroupsController, :type => :feature do
  self.use_transactional_fixtures = false

  let(:user) { FactoryGirl.create(:user) }
  let(:second_user) { FactoryGirl.create(:user) }
  let(:group) { FactoryGirl.create(:group, users: [user]) }


  before(:each) do

    visit new_user_session_path
    fill_in 'login_email', with: user.email
    fill_in 'login_password', with: user.password
    click_button 'submit_sign_in'

    ActionMailer::Base.deliveries.clear
  end

  before(:all) do
    DatabaseCleaner.strategy = :truncation
  end

  after(:all) do
    DatabaseCleaner.strategy = :transaction
  end



  describe 'delete recommendation from dashboard' do
    it 'should delete the current user from recommendation', js:true do
      user_recommendation = FactoryGirl.create(:recommendation, users: [user], group: nil)
      visit dashboard_path
      page.find('.remove-recommendation-current-user').click
      wait_for_ajax
      expect(Recommendation.where(id: user_recommendation.id)).to be_empty
    end

    it 'should hide the deleted recommendation', js:true do
      user_recommendation = FactoryGirl.create(:recommendation, users: [user], group: nil)
      visit dashboard_path
      page.find('.remove-recommendation-current-user').click
      wait_for_ajax
      expect(page).not_to have_content(user_recommendation.course.name)
    end

    it 'should remove user from recommendation', js:true do
      recommendation = FactoryGirl.create(:recommendation, users: [user, second_user], group: nil)
      visit dashboard_path
      page.find('.remove-recommendation-current-user').click
      wait_for_ajax
      expect(page).not_to have_content(recommendation.course.name)
    end

    it 'should not delete recommendation', js:true do
      recommendation = FactoryGirl.create(:recommendation, users: [user, second_user], group: nil)
      visit dashboard_path
      page.find('.remove-recommendation-current-user').click
      wait_for_ajax
      expect(Recommendation.find(recommendation.id).users).to match([second_user])
    end

    it 'should delete user from group recommendation', js: true do
      recommendation = FactoryGirl.create(:recommendation, users: [user], group: group)
      visit dashboard_path
      page.find('.remove-recommendation-current-user').click
      wait_for_ajax
      expect(page).not_to have_content(recommendation.course.name)
      expect(Recommendation.find(recommendation.id).users).to be_empty
      expect(Recommendation.find(recommendation.id).group).to eq group
    end

  end

  describe 'delete recommendation from my recommendation page' do
    it 'should delete the current user from recommendation', js:true do
      user_recommendation = FactoryGirl.create(:recommendation, users: [user], group: nil)
      visit recommendations_path
      page.find('.remove-recommendation-current-user').click
      wait_for_ajax
      expect(Recommendation.where(id: user_recommendation.id)).to be_empty
    end

    it 'should hide the deleted recommendation', js:true do
      user_recommendation = FactoryGirl.create(:recommendation, users: [user], group: nil)
      visit recommendations_path
      page.find('.remove-recommendation-current-user').click
      wait_for_ajax
      expect(page).not_to have_content(user_recommendation.course.name)
    end

    it 'should remove user from recommendation', js:true do
      recommendation = FactoryGirl.create(:recommendation, users: [user, second_user], group: nil)
      visit recommendations_path
      page.find('.remove-recommendation-current-user').click
      wait_for_ajax
      expect(page).not_to have_content(recommendation.course.name)
    end

    it 'should not delete recommendation', js:true do
      recommendation = FactoryGirl.create(:recommendation, users: [user, second_user], group: nil)
      visit recommendations_path
      page.find('.remove-recommendation-current-user').click
      wait_for_ajax
      expect(Recommendation.find(recommendation.id).users).to match([second_user])
    end

    it 'should delete user from group recommendation', js: true do
      recommendation = FactoryGirl.create(:recommendation, users: [user], group: group)
      visit recommendations_path
      page.find('.remove-recommendation-current-user').click
      wait_for_ajax
      expect(page).not_to have_content(recommendation.course.name)
      expect(Recommendation.find(recommendation.id).users).to be_empty
      expect(Recommendation.find(recommendation.id).group).to eq group
    end
  end

  describe 'delete group recommendation from groups dashboard' do

    it 'should not be possible to delete a recommendation as normal member' do
      recommendation = FactoryGirl.create(:recommendation, group: group)
      visit group_path(group)
      expect(page).to have_content(recommendation.course.name)
      expect(page).not_to have_selector('.remove-recommendation-group')
    end

    it 'should delete group recommendation', js:true do
      recommendation = FactoryGirl.create(:recommendation, group: group)
      UserGroup.set_is_admin(group.id, user.id, true)
      visit group_path(group)
      page.find('.remove-recommendation-group').click
      wait_for_ajax
      expect(Recommendation.where(id: recommendation.id)).to be_empty
    end

    it 'should hide deleted group recommendation', js:true do
      recommendation = FactoryGirl.create(:recommendation, group: group)
      UserGroup.set_is_admin(group.id, user.id, true)
      visit group_path(group)
      page.find('.remove-recommendation-group').click
      wait_for_ajax
      expect(page).not_to have_content(recommendation.course.name)
    end

  end

  describe 'delete group recommendation from groups recommendations page' do

    it 'should not be possible to delete a recommendation as normal member' do
      recommendation = FactoryGirl.create(:recommendation, group: group)
      visit "/groups/#{group.id}/recommendations"
      expect(page).to have_content(recommendation.course.name)
      expect(page).not_to have_selector('.remove-recommendation-group')
    end

    it 'should delete group recommendation', js:true do
      recommendation = FactoryGirl.create(:recommendation, group: group)
      UserGroup.set_is_admin(group.id, user.id, true)
      visit "/groups/#{group.id}/recommendations"
      page.find('.remove-recommendation-group').click
      wait_for_ajax
      expect(Recommendation.where(id: recommendation.id)).to be_empty
    end

    it 'should hide deleted group recommendation', js:true do
      recommendation = FactoryGirl.create(:recommendation, group: group)
      UserGroup.set_is_admin(group.id, user.id, true)
      visit "/groups/#{group.id}/recommendations"
      page.find('.remove-recommendation-group').click
      wait_for_ajax
      expect(page).not_to have_content(recommendation.course.name)
    end

  end


end
require 'rails_helper'

RSpec.describe Course, :type => :model do
  let!(:provider) { FactoryGirl.create(:mooc_provider) }
  let!(:course1) { FactoryGirl.create(:course,
                                      mooc_provider_id: provider.id,
                                      start_date: DateTime.new(2015,03,15),
                                      end_date: DateTime.new(2015,03,17)) }
  let!(:course2) { FactoryGirl.create(:course,
                                      mooc_provider_id: provider.id) }
  let!(:course3) { FactoryGirl.create(:course,
                                      mooc_provider_id: provider.id) }


  it "should set duration after creation" do
    expect(course1.calculated_duration_in_days).to eq(2)
  end

  it "should update duration after update of start/end_time" do
    course1.end_date = DateTime.new(2015,04,16)
    course1.save
    expect(course1.calculated_duration_in_days).to eq(32)
  end

  it "should save corresponding course, when setting previous_iteration_id" do
    course1.previous_iteration_id = course2.id
    course1.save
    expect(Course.find(course2.id).following_iteration_id).to eql course1.id
  end

  it "should save corresponding course, when setting following_iteration_id" do
    course1.following_iteration_id = course3.id
    course1.save
    expect(Course.find(course3.id).previous_iteration_id).to eql course1.id
  end

  it "should delete corresponding course connections, when destroying course" do
    course1.previous_iteration_id = course2.id
    course1.following_iteration_id = course3.id
    course1.save
    course1.destroy
    expect(Course.find(course3.id).previous_iteration_id).to eql nil
    expect(Course.find(course2.id).following_iteration_id).to eql nil
  end

end

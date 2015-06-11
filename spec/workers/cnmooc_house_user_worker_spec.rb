# -*- encoding : utf-8 -*-
require 'rails_helper'

RSpec.describe CnmoocHouseUserWorker do
  let(:user) { FactoryGirl.create(:user) }

  before(:each) do
    Sidekiq::Testing.inline!
  end

  it 'loads all users when no argument is passed' do
    expect_any_instance_of(CnmoocHouseConnector).to receive(:load_user_data).with(no_args)
    described_class.perform_async
  end

  it 'loads specified user when the corresponding id is passed' do
    expect_any_instance_of(CnmoocHouseConnector).to receive(:load_user_data).with([user])
    described_class.perform_async([user.id])
  end
end

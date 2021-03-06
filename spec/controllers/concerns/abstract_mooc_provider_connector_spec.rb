# -*- encoding : utf-8 -*-
require 'rails_helper'

RSpec.describe AbstractMoocProviderConnector do
  self.use_transactional_fixtures = false

  before(:all) do
    DatabaseCleaner.strategy = :truncation
  end

  after(:all) do
    DatabaseCleaner.strategy = :transaction
  end

  let(:mooc_provider) { FactoryGirl.create(:mooc_provider) }
  let(:course) { FactoryGirl.create(:full_course, mooc_provider_id: mooc_provider.id) }
  let(:second_course) { FactoryGirl.create(:full_course, mooc_provider_id: mooc_provider.id) }
  let(:user) { FactoryGirl.create(:user) }

  before(:each) do
    user.courses << course
    user.courses << second_course
  end

  let(:abstract_mooc_provider_connector) { described_class.new }

  it 'creates a valid update_map' do
    update_map = abstract_mooc_provider_connector.send(:create_enrollments_update_map, mooc_provider, user)
    expect(update_map.length).to eql 2
    update_map.each do |_, updated|
      expect(updated).to be false
    end
  end

  it 'evaluates the update_map and delete the right enrollment' do
    expect do
      update_map = abstract_mooc_provider_connector.send(:create_enrollments_update_map, mooc_provider, user)

      # set one enrollment to true -> prevent from deleting
      update_map.each_with_index do |(enrollment, _), index|
        update_map[enrollment] = true
        index >= 0 ? break : next
      end

      abstract_mooc_provider_connector.send(:evaluate_enrollments_update_map, update_map, user)
    end.to change(user.courses, :count).by(-1)
  end

  it 'throws exceptions when trying to call abstract methods' do
    expect { abstract_mooc_provider_connector.send(:mooc_provider) }.to raise_error NameError
    expect { abstract_mooc_provider_connector.send(:refresh_access_token, user) }.to raise_error NotImplementedError
    expect { abstract_mooc_provider_connector.send(:get_enrollments_for_user, user) }.to raise_error NotImplementedError
    expect { abstract_mooc_provider_connector.send(:handle_enrollments_response, 'test', user) }.to raise_error NotImplementedError
    expect { abstract_mooc_provider_connector.send(:send_connection_request, user, 'test') }.to raise_error NotImplementedError
    expect { abstract_mooc_provider_connector.send(:send_enrollment_for_course, user, '123') }.to raise_error NotImplementedError
    expect { abstract_mooc_provider_connector.send(:send_unenrollment_for_course, user, '123') }.to raise_error NotImplementedError
    expect { abstract_mooc_provider_connector.oauth_link 'destination', 'csrf_token' }.to raise_error NotImplementedError
  end

  it 'handles internet connection error' do
    allow(abstract_mooc_provider_connector).to receive(:get_enrollments_for_user).and_raise SocketError
    expect { abstract_mooc_provider_connector.send(:fetch_user_data, user) }.not_to raise_error
  end

  it 'handles API not found error' do
    allow(abstract_mooc_provider_connector).to receive(:get_enrollments_for_user).and_raise RestClient::ResourceNotFound
    expect { abstract_mooc_provider_connector.send(:fetch_user_data, user) }.not_to raise_error
  end
end

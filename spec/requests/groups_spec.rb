# -*- encoding : utf-8 -*-
require 'rails_helper'

RSpec.describe 'Groups', type: :request do
  before(:each) do
    sign_in_as_a_valid_user
  end

  describe 'GET /groups' do
    it 'works! (now write some real specs)' do
      get groups_path
      expect(response).to have_http_status(200)
    end
  end
end

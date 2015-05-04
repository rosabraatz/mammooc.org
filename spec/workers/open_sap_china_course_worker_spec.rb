require 'rails_helper'

RSpec.describe OpenSAPChinaCourseWorker do

  let!(:mooc_provider) { FactoryGirl.create(:mooc_provider, name: 'openSAP China') }

  let(:open_sap_china_course_worker){ OpenSAPChinaCourseWorker.new }

  it 'should deliver MOOCProvider' do
    expect(open_sap_china_course_worker.mooc_provider).to eql mooc_provider
  end

  it 'should get an API response' do
    pending
    expect(open_sap_china_course_worker.get_course_data).not_to be_nil
  end

end

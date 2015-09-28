require 'rails_helper'

RSpec.describe SupportRequest, type: :model do
  let(:support_request){ SupportRequest.new(from: create(:user)) }

  describe '.assign_attributes' do
    before{ support_request.assign_attributes(subject: 'subject') }
    subject{ support_request.subject }
    it { is_expected.to eq 'subject' }
  end

  describe '.default_email' do
    subject{ support_request.default_email }
    it { expect{subject}.to_not raise_error }
  end

  describe '.default_subject' do
    subject{ support_request.default_subject }
    it { expect{subject}.to_not raise_error }
  end

  describe '.recipient_email' do
    subject{ support_request.recipient_email }
    it { expect{subject}.to_not raise_error }
  end

  describe '.send!' do
    subject{ support_request.send! }
    it { expect{subject}.to change{ SupportRequestWorker.jobs.length }.by 1 }
  end
end
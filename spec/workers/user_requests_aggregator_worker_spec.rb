require 'rails_helper'

RSpec.describe UserRequestsAggregatorWorker, type: :model do
  let(:date1) { Date.today + 5.hours }
  let(:date2) { Date.today + 6.hours }
  let(:ip1)   { '127.0.0.1' }
  let(:ip2)   { '127.0.0.2' }

  before do
    User.clean_requests_logs
    User.new(id: 1).log_request date1, ip1
    User.new(id: 1).log_request date1, ip1
    User.new(id: 1).log_request date1, ip2
    User.new(id: 1).log_request date2, ip1
    User.new(id: 1).log_request date2, ip2
  end

  it 'creates user requests' do
    UserRequestsAggregatorWorker.new.perform
    expect(UserRequest.count).to eq 4
    expect(UserRequest.where(ip: ip1, date: date1.to_date, hour: date1.hour).first.quantity).to eq 2
  end

  context 'when data exists' do
    before do
      UserRequest.create!(ip: ip1, date: date1.to_date, hour: date1.hour, quantity: 1)
    end

    it 'merges user requests' do
      UserRequestsAggregatorWorker.new.perform
      expect(UserRequest.count).to eq 4
      expect(UserRequest.where(ip: ip1, date: date1.to_date, hour: date1.hour).first.quantity).to eq 3
    end
  end
end
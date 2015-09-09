load 'lib/tasks/maintain.rake'

RSpec.describe 'maintain', type: :rake do
  context 'maintain:strip_companies' do
    before do
      FactoryGirl.create(:company, name: 'Duplicate')
      FactoryGirl.create(:company, name: 'Duplicate ')
      FactoryGirl.create(:company, name: ' Duplicate')
      FactoryGirl.create(:company, name: ' Duplicate ')
      subject.execute
    end

    it do
      expect(Company.where(name: 'Duplicate').count).to eq 4
    end
  end

  context 'maintain:merge_companies' do
    let!(:companies) do
      companies = []
      2.times do
        companies << FactoryGirl.build(:company, name: 'Duplicate')
        companies.last.save!(validate: false)
      end
      companies
    end

    let!(:users) do
      users = []
      2.times do |i|
        users << FactoryGirl.create(:user)
        users.last.company = companies[i]
        users.last.save!(validate: false)
      end
      users
    end

    before do
      subject.execute
    end

    it do
      expect(Company.where(name: 'Duplicate').count).to eq 1
      expect(users.each(&:reload).map(&:company_id)).to eq [companies.first.id]*2
    end
  end
end



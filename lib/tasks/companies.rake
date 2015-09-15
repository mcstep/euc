namespace :companies do
  task :strip => :environment do
    Company.all.each do |company|
      company.name.strip!
      company.save!(validate: false)
    end
  end

  task :merge => :environment do
    Company.group(:name).having('count(name) > 1').pluck(:name).each do |duplicate_name|
      company       = Company.where(name: duplicate_name).order(:id).first
      duplicate_ids = Company.where(name: duplicate_name).where.not(id: company.id).pluck(:id)

      company.transaction do
        [Customer, Domain, Partner, User].each do |model|
          model.where(company_id: duplicate_ids).update_all(company_id: company.id)
        end

        Company.where(id: duplicate_ids).delete_all
      end
    end
  end

  task :find_duplicates => :environment do
    users = User.select(
      "company_id, SUBSTRING(email FROM POSITION('@' IN email)+1) AS domain"
    ).includes(:company).group('company_id, domain')

    users.group_by(&:domain).each do |domain, users|
      next if users.length < 2
      puts "#{domain}: #{users.map(&:company).map(&:name).inspect}"
    end
  end
end
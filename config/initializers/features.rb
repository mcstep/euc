if FeatureToggle.table_exists?
  repo = Feature::Repository::ActiveRecordRepository.new(FeatureToggle)
  Feature.set_repository(repo)
end

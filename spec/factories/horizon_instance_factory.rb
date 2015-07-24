FactoryGirl.define do
  factory :horizon_instance do
    view_group_name 'HorizonViewUsers'
    group_region    'dldc'
    api_host        { FFaker::Internet.domain_name }
  end
end
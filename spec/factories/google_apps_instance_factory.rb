FactoryGirl.define do
  factory :google_apps_instance do
    key               File.open(Rails.root.join 'config','privatekey.p12').read
    key_password      'notasecret'
    initial_password  FFaker::Internet.password
    service_account   FFaker::Internet.email
    act_on_behalf     FFaker::Internet.email
  end
end
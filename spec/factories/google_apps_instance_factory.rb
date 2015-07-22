FactoryGirl.define do
  factory :google_apps_instance do
    key               File.open(Rails.root.join 'spec', 'factories', 'data', 'test_google_apps.p12').read
    key_password      'notasecret'
    initial_password  FFaker::Internet.password
    service_account   FFaker::Internet.email
    act_on_behalf     FFaker::Internet.email

    factory :test_google_apps_instance do
      key               File.open(Rails.root.join 'spec', 'factories', 'data', 'test_google_apps.p12').read
      key_password      'notasecret'
      initial_password  'Passw0rd1'
      service_account   '1017868876365-qanhsqob5de941vq704utiu6sjmgibkc@developer.gserviceaccount.com'
      act_on_behalf     'administrator@vmwdev.com'
    end
  end
end
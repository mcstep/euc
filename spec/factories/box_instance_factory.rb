FactoryGirl.define do
  factory :box_instance do
    group_name          'SalesforceUsers'
    group_region        'dldc'
    token_retriever_url 'http://box-token-generator.herokuapp.com'
    username            { FFaker::Internet.email }
    password            { FFaker::Internet.password }
    client_id           { FFaker::Guid.guid }
    client_secret       { FFaker::Lorem.characters(36) }
    access_token        { FFaker::Lorem.characters(36) }
    refresh_token       { FFaker::Lorem.characters(36) }

    factory :staging_box_instance do
      username        'services+api.user@vmwdemo.com'
      password        'BoxPassw0rd123'
      client_id       'f6yaohk4kjnopankqd9xgngd8l6awdc1'
      client_secret   'tjQ8iCVTzKnLLDw55gx5fERkj4AjsRn8'
    end
  end
end
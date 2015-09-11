FactoryGirl.define do
  factory :salesforce_instance do
    group_name      'SalesforceUsers'
    group_region    'dldc'
    username        { FFaker::Internet.email }
    password        { FFaker::Internet.password }
    security_token  { FFaker::Lorem.characters(36) }
    client_id       { FFaker::Guid.guid }
    client_secret   { FFaker::Lorem.characters(36) }
    time_zone       'America/New_York'
    common_locale   'en_US'
    language_locale 'en_US'
    email_encoding  'ISO-8859-1'
    profile_id      '00e37000000h16ZAAQ'

    factory :staging_salesforce_instance do

      username        'mbasanta@vmtestdrive.com'
      password        'Passw0rd1'
      security_token  'rOPaTAfxG9p6N8sxlLsjmkw5O'
      client_id       '3MVG98SW_UPr.JFjd_11wVTsp4Nhu865RGa6OJ3wd_SCCZUzyCj5Ix.3BvmOVYpPjzPgAKnmqeNrVFo8KboQp'
      client_secret   '605335628658027112'
    end

    factory :opportunities_staging_salesforce_instance do
      username        'eucintegrationuser@vmware.com.vmw.dev4'
      password        'VMware1@23Az52gBYvxLZla1ZBjDA9SDhL'
      security_token  ''
      client_id       '3MVG9Oe7T3Ol0ea7VXyLoN8ib2X9x_.9965dNjpQ8UQG_YL5CKxwBWzCNdwCnHxhdcSTCGlhjKpfTEOhhMQap'
      client_secret   '7956755793130956252'
      host            'test.salesforce.com'
    end
  end
end
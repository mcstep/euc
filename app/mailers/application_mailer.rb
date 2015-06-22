class ApplicationMailer < ActionMailer::Base
  default from: %("VMware EUC Demo Portal" <noreply@vmwdemo.com>)
  default reply_to: 'eucdemohelpp@vmware.com'
  layout 'mailer'
end

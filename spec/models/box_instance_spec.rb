require 'rails_helper'

RSpec.describe BoxInstance, :vcr, type: :model do
  let(:box_instance) do
    create :staging_box_instance,
      access_token: 'QZUM4G8nqYL5osC8PJOnwB8YruBv37Ot',
      refresh_token: 'U0gmdLj6v281ahzlq2smaiXdm6mqXFYZsuzeeeElg4Eotl3xVOBZoAqJ99UqdMrE'
  end

  describe '.register' do
    subject{ box_instance.register('foo111@bar.com', 'Foo Bar') }
    after{ box_instance.unregister('250307578') }

    it do
      is_expected.to eq(
        "type"=>"user", "id"=>"250307578", "name"=>"Foo Bar", "login"=>"foo111@bar.com",
        "created_at"=>"2015-09-17T08:12:11-07:00", "modified_at"=>"2015-09-17T08:12:11-07:00",
        "language"=>"en", "timezone"=>"America/Los_Angeles", "space_amount"=>2147483648,
        "space_used"=>0, "max_upload_size"=>5368709120, "status"=>"active", "job_title"=>"",
        "phone"=>"", "address"=>"", "avatar_url"=>"https://vmtestdrive.app.box.com/api/avatar/large/250307578"
      )
    end
  end
end
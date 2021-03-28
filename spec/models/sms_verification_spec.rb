# == Schema Information
#
# Table name: sms_verifications
#
#  id                  :uuid             not null, primary key
#  code                :string
#  error               :string
#  phone_number        :string
#  sent_at             :datetime
#  sms_verifiable_type :string           not null
#  verified_at         :datetime
#  created_at          :datetime         not null
#  updated_at          :datetime         not null
#  messagebird_id      :string
#  sms_verifiable_id   :uuid             not null
#
# Indexes
#
#  index_sms_verifications_on_sms_verifiable  (sms_verifiable_type,sms_verifiable_id)
#
require 'rails_helper'

RSpec.describe SmsVerification, type: :model do
  pending "add some examples to (or delete) #{__FILE__}"
end

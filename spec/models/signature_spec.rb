# == Schema Information
#
# Table name: signatures
#
#  id                :uuid             not null, primary key
#  document_read     :boolean
#  ip                :string
#  otp               :string
#  signed_at         :datetime
#  created_at        :datetime         not null
#  updated_at        :datetime         not null
#  document_id       :uuid             not null
#  meeting_member_id :uuid             not null
#
# Indexes
#
#  index_signatures_on_document_id        (document_id)
#  index_signatures_on_meeting_member_id  (meeting_member_id)
#
# Foreign Keys
#
#  fk_rails_...  (document_id => documents.id)
#  fk_rails_...  (meeting_member_id => meeting_members.id)
#
require 'rails_helper'

RSpec.describe Signature, type: :model do
  pending "add some examples to (or delete) #{__FILE__}"
end

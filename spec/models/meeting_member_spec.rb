# == Schema Information
#
# Table name: meeting_members
#
#  id               :uuid             not null, primary key
#  audio            :boolean          default(TRUE)
#  memberable_type  :string           not null
#  must_sign        :boolean
#  video            :boolean          default(TRUE)
#  xfdf             :text
#  xfdf_merged      :boolean          default(FALSE)
#  created_at       :datetime         not null
#  updated_at       :datetime         not null
#  company_id       :uuid
#  meeting_id       :uuid             not null
#  memberable_id    :uuid             not null
#  signed_member_id :string
#
# Indexes
#
#  index_meeting_members_on_company_id  (company_id)
#  index_meeting_members_on_meeting_id  (meeting_id)
#  index_meeting_members_on_memberable  (memberable_type,memberable_id)
#
# Foreign Keys
#
#  fk_rails_...  (meeting_id => meetings.id)
#
require 'rails_helper'

RSpec.describe MeetingMember, type: :model do
  pending "add some examples to (or delete) #{__FILE__}"
end

# == Schema Information
#
# Table name: documents
#
#  id               :uuid             not null, primary key
#  read_only        :boolean
#  require_read     :boolean
#  signature_fields :jsonb
#  state            :string
#  title            :string
#  xfdf             :text
#  xfdf_merged      :boolean          default(FALSE)
#  created_at       :datetime         not null
#  updated_at       :datetime         not null
#  created_by_id    :uuid             not null
#  meeting_id       :uuid             not null
#
# Indexes
#
#  index_documents_on_created_by_id  (created_by_id)
#  index_documents_on_meeting_id     (meeting_id)
#
# Foreign Keys
#
#  fk_rails_...  (meeting_id => meetings.id)
#
require 'rails_helper'

RSpec.describe Document, type: :model do
  pending "add some examples to (or delete) #{__FILE__}"
end

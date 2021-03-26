# == Schema Information
#
# Table name: documents
#
#  id            :uuid             not null, primary key
#  read_only     :boolean
#  require_read  :boolean
#  state         :string
#  title         :string
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#  created_by_id :uuid             not null
#  meeting_id    :uuid             not null
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
class Document < ApplicationRecord
  belongs_to :meeting
  belongs_to :created_by, class_name: "User"

  has_many :signatures
  has_many :meeting_members, through: :signatures
  has_many :document_accesses

  has_one_attached :file
end

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
require 'aasm'
require 'prawn'
class Document < ApplicationRecord
  has_paper_trail
  include AASM
  belongs_to :meeting
  belongs_to :created_by, class_name: "User"

  has_many :signatures, dependent: :destroy
  has_many :meeting_members, through: :signatures
  has_many :document_accesses

  validates :file, attached: true, content_type: 'application/pdf'
  validate :enforce_maximum_documents, on: :create

  after_create :initialize_signatures
  after_create_commit { broadcast_to_meeting("create") }
  after_update_commit { broadcast_to_meeting("update") }
  after_destroy_commit { broadcast_to_meeting("destroy") }

  has_one_attached :file

  aasm(column: :state, logger: Rails.logger) do
    state :created, initial: true
    state :incomplete
    state :finalized

    event :sign, after: :broadcast_update do
      transitions from: [:created, :incomplete], to: :finalized, if: :signing_complete?, after: :add_signature_page
      transitions from: [:created, :incomplete], to: :incomplete, unless: :signing_complete?
    end
  end

  def signed_by?(memberable)
    signature = signatures.includes(:meeting_member).find_by(meeting_member: { memberable: memberable })
    signature.signed?
  end

  private

  def broadcast_to_meeting(type)
    DocumentsChannel.broadcast_to meeting, type: type, document_id: id
  end

  def initialize_signatures
    meeting.meeting_members.each do |member|
      signatures.create(meeting_member: member)
    end
  end

  def broadcast_update
    broadcast_to_meeting("update")
  end

  def signing_complete?
    !signatures.includes(:meeting_member).find_by(signed_at: nil, meeting_member: { must_sign: true}).present?
  end

  def generate_signatures
    pdf = Prawn::Document.new
    pdf.formatted_text([{ text: I18n.t("pdf_gen.signatures"), size: 24 }])
    cells = []
    signatures.each_with_index do |signature, i|
      cell = signature.render(pdf)
      if i % 2 == 0
        cells.push [cell]
      else
        cells.last.push cell
      end
    end
    pdf.table cells
    pdf.render
  end

  def add_signature_page
    pdf = CombinePDF.new
    pdf << CombinePDF.parse(file.download)
    pdf << CombinePDF.parse(generate_signatures)
    file.attach(io: StringIO.new(pdf.to_pdf), filename: "#{id}.pdf")
    broadcast_to_meeting("update")
  end

  def enforce_maximum_documents
    # STRIPE FOR LUCA
    max_documents = 2
    if meeting.documents.count >= max_documents
      errors.add(:meeting, I18n.t("meetings.errors.maximum_documents", maximum: max_documents))
    end
  end
end

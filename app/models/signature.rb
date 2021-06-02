# == Schema Information
#
# Table name: signatures
#
#  id                :uuid             not null, primary key
#  document_read     :boolean
#  ip                :string
#  otp               :string
#  signed_at         :datetime
#  state             :string
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
require 'digest/sha1'
class Signature < ApplicationRecord
  has_paper_trail
  belongs_to :document
  belongs_to :meeting_member

  has_one :sms_verification, as: :sms_verifiable

  def sign!(ip:)
    if signable?
      update(signed_at: Time.now, otp: sms_verification.code, ip: ip)
      document.sign!
      if meeting_member.memberable_type == "Participant"
        meeting_member.memberable.finalize! unless meeting_member.memberable.finalized?
      end
    end
  end

  def render(pdf)
    return unless signed?
    data = [
      [{ content: meeting_member.memberable.name, colspan: 2, align: :center }],
      [{ content: I18n.t("pdf_gen.signed_at"), size: 10, font_style: :bold }, { content: signed_at.to_s, size: 10 }],
      [{ content: I18n.t("pdf_gen.ip"), size: 10, font_style: :bold }, { content: ip, size: 10 }],
      [{ content: I18n.t("pdf_gen.otp"), size: 10, font_style: :bold }, { content: otp, size: 10 }]
    ]
    pdf.make_table(data, cell_style: { borders: [] })
  end

  def watermark(pdf)
    otp_sha = Digest::SHA1.hexdigest otp

    data = [
      # Make it all one "row", since we are going vertical
      [
        { content: I18n.t("pdf_gen.watermark", signed_at: signed_at.strftime("%d/%m/%Y"), signed_by: meeting_member.memberable.name) + "\n#{otp_sha}", size: 8, rotate: -90 }
      ]
    ]
    pdf.make_table(data, cell_style: { borders: [] })
  end

  def signed?
    signed_at.present?
  end

  def signable?
    sms_verification&.verified? && !require_read? && meeting_member.must_sign
  end

  def require_read?
    document.require_read && !document_read
  end
end

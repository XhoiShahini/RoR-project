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
class Signature < ApplicationRecord
  belongs_to :document
  belongs_to :meeting_member

  has_one :sms_verification, as: :sms_verifiable

  def sign!(ip:)
    if signable?
      update(signed_at: Time.now, otp: sms_verification.code, ip: ip)
      document.sign!
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

class AddAcceptedSignatureAgreementAtToUser < ActiveRecord::Migration[6.1]
  def change
    add_column :users, :accepted_signature_agreement_at, :datetime
  end
end

class CreateSignatures < ActiveRecord::Migration[6.1]
  def change
    create_table :signatures, id: :uuid do |t|
      t.references :document, null: false, foreign_key: true, type: :uuid
      t.references :meeting_member, null: false, foreign_key: true, type: :uuid
      t.datetime :signed_at
      t.string :ip
      t.string :otp
      t.boolean :document_read

      t.timestamps
    end
  end
end

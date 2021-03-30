class CreateSmsVerifications < ActiveRecord::Migration[6.1]
  def change
    create_table :sms_verifications, id: :uuid do |t|
      t.references :sms_verifiable, null: false, polymorphic: true, type: :uuid
      t.string :code
      t.string :error
      t.string :phone_number
      t.string :state
      t.datetime :sent_at
      t.datetime :verified_at
      t.string :messagebird_id

      t.timestamps
    end
  end
end

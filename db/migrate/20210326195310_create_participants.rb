class CreateParticipants < ActiveRecord::Migration[6.1]
  def change
    create_table :participants, id: :uuid do |t|
      t.references :account, null: false, foreign_key: true, type: :uuid
      t.string :first_name
      t.string :last_name
      t.string :email
      t.string :phone_number
      t.string :state
      t.datetime :accepted_terms_at
      t.datetime :accepted_privacy_at

      t.timestamps
    end
  end
end

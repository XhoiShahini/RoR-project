class CreateMeetings < ActiveRecord::Migration[6.1]
  def change
    create_table :meetings, id: :uuid do |t|
      t.references :account, null: false, foreign_key: true, type: :uuid
      t.references :host, null: false, type: :uuid
      t.string :title
      t.string :state
      t.datetime :starts_at
      t.datetime :completed_at

      t.timestamps
    end
  end
end

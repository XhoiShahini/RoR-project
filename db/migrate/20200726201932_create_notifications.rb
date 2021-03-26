class CreateNotifications < ActiveRecord::Migration[6.0]
  def change
    create_table :notifications, id: :uuid do |t|
      t.belongs_to :account, null: false, type: :uuid
      t.belongs_to :recipient, polymorphic: true, null: false, type: :uuid
      t.string :type
      t.jsonb :params
      t.datetime :read_at

      t.timestamps
    end
  end
end

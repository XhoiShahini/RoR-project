class CreateAccountUsers < ActiveRecord::Migration[6.0]
  def change
    create_table :account_users, id: :uuid do |t|
      t.belongs_to :account, foreign_key: true, type: :uuid
      t.belongs_to :user, foreign_key: true, type: :uuid
      t.jsonb :roles, null: false, default: {}

      t.timestamps
    end
  end
end

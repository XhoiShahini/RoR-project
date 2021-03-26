class CreateApiTokens < ActiveRecord::Migration[6.0]
  def change
    create_table :api_tokens, id: :uuid do |t|
      t.references :user, null: false, foreign_key: true, type: :uuid
      t.string :token
      t.string :name
      t.jsonb :metadata, default: {}
      t.boolean :transient, default: false
      t.datetime :last_used_at
      t.datetime :expires_at

      t.timestamps
    end

    add_index :api_tokens, :token, unique: true
  end
end

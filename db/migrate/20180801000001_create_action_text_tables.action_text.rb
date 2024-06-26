# This migration comes from action_text (originally 201805281641)
class CreateActionTextTables < ActiveRecord::Migration[6.0]
  def change
    create_table :action_text_rich_texts, id: :uuid do |t|
      t.string :name, null: false
      t.text :body, limit: 16777215
      t.references :record, null: false, polymorphic: true, index: false, type: :uuid

      t.datetime :created_at, null: false
      t.datetime :updated_at, null: false

      t.index [:record_type, :record_id, :name], name: "index_action_text_rich_texts_uniqueness", unique: true
    end
  end
end

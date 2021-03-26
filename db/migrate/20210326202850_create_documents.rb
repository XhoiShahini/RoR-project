class CreateDocuments < ActiveRecord::Migration[6.1]
  def change
    create_table :documents, id: :uuid do |t|
      t.references :meeting, null: false, foreign_key: true, type: :uuid
      t.references :created_by, null: false, type: :uuid
      t.string :title
      t.string :state
      t.boolean :require_read
      t.boolean :read_only

      t.timestamps
    end
  end
end

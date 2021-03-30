class CreateDocumentAccesses < ActiveRecord::Migration[6.1]
  def change
    create_table :document_accesses, id: :uuid do |t|
      t.references :document, null: false, foreign_key: true, type: :uuid
      t.references :meeting_member, null: false, foreign_key: true, type: :uuid
      t.string :ip

      t.timestamps
    end
  end
end

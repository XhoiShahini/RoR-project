class CreateMeetingMembers < ActiveRecord::Migration[6.1]
  def change
    create_table :meeting_members, id: :uuid do |t|
      t.references :meeting, null: false, foreign_key: true, type: :uuid
      t.references :memberable, null: false, polymorphic: true, type: :uuid
      t.string :company
      t.boolean :must_sign

      t.timestamps
    end
  end
end

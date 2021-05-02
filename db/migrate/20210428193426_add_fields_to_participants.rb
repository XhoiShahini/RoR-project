class AddFieldsToParticipants < ActiveRecord::Migration[6.1]
  def change
    add_column :participants, :accepted_data_at, :datetime
    add_column :participants, :accepted_media_at, :datetime
    add_column :participants, :accepted_signature_at, :datetime
  end
end

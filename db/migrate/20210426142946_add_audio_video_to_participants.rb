class AddAudioVideoToParticipants < ActiveRecord::Migration[6.1]
  def change
    add_column :participants, :audio, :boolean, default: true
    add_column :participants, :video, :boolean, default: true
  end
end

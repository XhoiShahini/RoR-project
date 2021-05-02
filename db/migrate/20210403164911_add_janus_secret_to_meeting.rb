class AddJanusSecretToMeeting < ActiveRecord::Migration[6.1]
  def change
    add_column :meetings, :janus_secret, :string
  end
end

class DropJanusTokens < ActiveRecord::Migration[6.1]
  def change
    safety_assured do
      remove_column :meeting_members, :janus_token, :string
      remove_column :meetings, :janus_secret, :string
    end
  end
end

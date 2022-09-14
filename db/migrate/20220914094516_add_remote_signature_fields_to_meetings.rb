class AddRemoteSignatureFieldsToMeetings < ActiveRecord::Migration[6.1]
  def change
    add_column :meetings, :is_api, :boolean, default: false
    add_column :meetings, :return_url, :string
  end
end

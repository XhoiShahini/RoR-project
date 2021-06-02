class AddAcceptedMarketingAtToUsers < ActiveRecord::Migration[6.1]
  def change
    add_column :users, :accepted_marketing_at, :datetime
  end
end

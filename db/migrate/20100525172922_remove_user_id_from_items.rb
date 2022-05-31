class RemoveUserIdFromItems < ActiveRecord::Migration
  def self.up
    remove_column :items,     :user_id
  end

  def self.down
    add_column     :items,     :user_id,     :integer
  end
end

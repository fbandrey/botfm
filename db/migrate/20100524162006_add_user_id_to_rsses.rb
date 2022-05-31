class AddUserIdToRsses < ActiveRecord::Migration
  def self.up
    add_column    :rsses,   :user_id,   :integer
  end

  def self.down
    remove_column :rsses,   :user_id
  end
end

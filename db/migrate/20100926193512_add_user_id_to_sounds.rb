class AddUserIdToSounds < ActiveRecord::Migration
  def self.up
    add_column    :sounds,      :user_id,     :integer
  end

  def self.down
    remove_column :sounds,      :user_id
  end
end

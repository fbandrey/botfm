class AddNameToUsers < ActiveRecord::Migration
  def self.up
    add_column    :users,   :name,    :string,    :limit => 512
  end

  def self.down
    remove_column :users,   :name
  end
end

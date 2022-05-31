class AddSoundsCountToUsers < ActiveRecord::Migration
  def self.up
    add_column    :users,     :sounds_count,    :integer,     :default => 0
    add_column    :users,     :description,     :text
  end

  def self.down
    remove_column :users,     :description
    remove_column :users,     :sounds_count
  end
end

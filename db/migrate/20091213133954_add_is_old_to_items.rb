class AddIsOldToItems < ActiveRecord::Migration
  def self.up
    add_column    :items,     :is_old,    :boolean,     :default => false
    Item.update_all "is_old = false" 
  end

  def self.down
    remove_column :items,     :is_old
  end
end

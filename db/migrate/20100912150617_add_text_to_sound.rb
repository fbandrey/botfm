class AddTextToSound < ActiveRecord::Migration
  def self.up
    add_column    :sounds,  :text,  :text
  end

  def self.down
    remove_column :sounds,  :text
  end
end

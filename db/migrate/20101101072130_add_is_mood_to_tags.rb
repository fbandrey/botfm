class AddIsMoodToTags < ActiveRecord::Migration
  def self.up
    add_column    :tags,    :is_mood,   :boolean,     :default => false
  end

  def self.down
    remove_column :tags,    :is_mood
  end
end

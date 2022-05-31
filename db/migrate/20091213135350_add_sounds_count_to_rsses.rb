class AddSoundsCountToRsses < ActiveRecord::Migration
  def self.up
    add_column    :rsses,       :sounds_count,      :integer,    :default => 0
  end

  def self.down
    remove_column :rsses,       :sounds_count
  end
end

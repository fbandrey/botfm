class AddStopSoundsToAdmin < ActiveRecord::Migration
  def self.up
    add_column    :users,    :stop_sounds,   :boolean,     :default => false
    User.update_all "stop_sounds = false"
  end

  def self.down
    remove_column :users,    :stop_sounds
  end
end

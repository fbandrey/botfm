class AddListenCountToRsses < ActiveRecord::Migration
  def self.up
    add_column    :rsses,   :listen_count,    :integer,     :default => 0
    add_column    :tags,    :listen_count,    :integer,     :default => 0
    Rss.update_all "listen_count = 0"
    Tag.update_all "listen_count = 0"
  end

  def self.down
    remove_column :tags,    :listen_count
    remove_column :rsses,   :listen_count
  end
end

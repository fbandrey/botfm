class CreateSongs < ActiveRecord::Migration
  def self.up
    create_table :songs do |t|
      t.string      :content_type,  :limit => 512
      t.string      :filename,      :limit => 512
      t.integer     :size

      t.timestamps
    end
  end

  def self.down
    drop_table :songs
  end
end

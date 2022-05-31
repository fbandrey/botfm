class CreateItems < ActiveRecord::Migration
  def self.up
    create_table :items do |t|
      t.string          :content,       :limit => 1024
      t.integer         :rss_id

      t.timestamps
    end
  end

  def self.down
    drop_table :items
  end
end

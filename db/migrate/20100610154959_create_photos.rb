class CreatePhotos < ActiveRecord::Migration
  def self.up
    create_table :photos do |t|
      t.integer     :parent_id
      t.string      :content_type,  :limit => 512
      t.string      :filename,      :limit => 512
      t.string      :thumbnail,     :limit => 512
      t.integer     :size
      t.integer     :width
      t.integer     :height

      t.integer     :user_id

      t.timestamps
    end
  end

  def self.down
    drop_table :photos
  end
end

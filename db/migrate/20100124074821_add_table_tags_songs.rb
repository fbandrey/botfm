class AddTableTagsSongs < ActiveRecord::Migration
  def self.up
    create_table "songs_tags", :id => false, :force => true do |t|
      t.column "song_id", :integer
      t.column "tag_id", :integer
    end
  end

  def self.down
    drop_table "songs_tags"
  end
end

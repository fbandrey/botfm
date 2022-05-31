class CreateRssesTags < ActiveRecord::Migration
  def self.up
    create_table "rsses_tags", :id => false, :force => true do |t|
      t.column "rss_id", :integer
      t.column "tag_id", :integer
    end
  end

  def self.down
    drop_table "rsses_tags"
  end
end

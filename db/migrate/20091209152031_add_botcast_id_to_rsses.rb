class AddBotcastIdToRsses < ActiveRecord::Migration
  def self.up
    add_column    :rsses,     :botcast_id,      :integer
  end

  def self.down
    remove_column :rsses,     :botcast_id
  end
end

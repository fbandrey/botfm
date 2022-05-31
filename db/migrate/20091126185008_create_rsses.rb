class CreateRsses < ActiveRecord::Migration
  def self.up
    create_table :rsses do |t|
      t.string            :title,           :limit => 512
      t.text              :description
      t.integer           :items_count,     :default => 0

      t.timestamps
    end
  end

  def self.down
    drop_table :rsses
  end
end

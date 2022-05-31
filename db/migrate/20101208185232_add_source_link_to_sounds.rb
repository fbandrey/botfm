class AddSourceLinkToSounds < ActiveRecord::Migration
  def self.up
    add_column    :sounds,    :source_link,     :string
  end

  def self.down
    remove_column :sounds,    :source_link
  end
end

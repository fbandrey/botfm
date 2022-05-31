class AddRatingToUsersAndTags < ActiveRecord::Migration
  def self.up
    add_column    :users,     :rating,    :integer,     :default => 0
    add_column    :tags,      :rating,    :integer,     :default => 0
    User.update_all "rating = 0"
    Tag.update_all "rating = 0"
  end

  def self.down
    remove_column :tags,      :rating
    remove_column :users,     :rating
  end
end

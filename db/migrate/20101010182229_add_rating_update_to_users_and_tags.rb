class AddRatingUpdateToUsersAndTags < ActiveRecord::Migration
  def self.up
    add_column    :users,     :rating_update,    :datetime,     :default => DateTime.now
    add_column    :tags,      :rating_update,    :datetime,     :default => DateTime.now
    User.update_all "rating_update = '#{DateTime.now}'"
    Tag.update_all "rating_update = '#{DateTime.now}'"
  end

  def self.down
    remove_column :tags,      :rating_update
    remove_column :users,     :rating_update
  end
end

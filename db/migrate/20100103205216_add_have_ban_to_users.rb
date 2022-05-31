class AddHaveBanToUsers < ActiveRecord::Migration
  def self.up
    add_column    :users,       :have_ban,      :boolean,     :default => false
    User.update_all "have_ban = false"
  end

  def self.down
    remove_column :users,       :have_ban
  end
end

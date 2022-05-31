class AddFieldsToUsers < ActiveRecord::Migration
  def self.up
    add_column    :users,   :color_theme,   :integer,   :default => 0
    add_column    :users,   :homepage,      :string,    :limit => 512
    add_column    :users,   :icq,           :string,    :limit => 512
    add_column    :users,   :skype,         :string,    :limit => 512
    add_column    :users,   :facebook,      :string,    :limit => 512
    add_column    :users,   :myspace,       :string,    :limit => 512
    add_column    :users,   :twitter,       :string,    :limit => 512
    add_column    :users,   :promodj,       :string,    :limit => 512
  end

  def self.down
    remove_column :users,   :promodj
    remove_column :users,   :twitter
    remove_column :users,   :myspace
    remove_column :users,   :facebook
    remove_column :users,   :skype
    remove_column :users,   :icq
    remove_column :users,   :homepage
    remove_column :users,   :color_theme
  end
end

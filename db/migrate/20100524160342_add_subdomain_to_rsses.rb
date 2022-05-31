class AddSubdomainToRsses < ActiveRecord::Migration
  def self.up
    add_column    :rsses,   :subdomain,   :string,    :limit => 512
  end

  def self.down
    remove_column :rsses,   :subdomain
  end
end

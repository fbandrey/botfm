class RemoveTableRssesTags < ActiveRecord::Migration
  def self.up
    drop_table "rsses_tags"
    remove_column   :rsses,   :subdomain
  end

  def self.down
    add_column   :rsses,   :subdomain,  :string,    :limit => 512
    create_table "rsses_tags" do |t|
    end
  end
end

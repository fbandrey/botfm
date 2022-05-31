class AddIsPublishedToDocuments < ActiveRecord::Migration
  def self.up
    add_column    :documents,     :is_published,    :boolean,     :default => false
    add_column    :documents,     :title_on_main,   :string
    Document.update_all "is_published = false"
  end

  def self.down
    remove_column :documents,     :title_on_main
    remove_column :documents,     :is_published
  end
end

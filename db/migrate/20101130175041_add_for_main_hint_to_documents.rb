class AddForMainHintToDocuments < ActiveRecord::Migration
  def self.up
    add_column    :documents,   :for_main_hint,     :boolean,     :default => false
    Document.update_all "for_main_hint = false"
  end

  def self.down
    remove_column :documents,   :for_main_hint
  end
end

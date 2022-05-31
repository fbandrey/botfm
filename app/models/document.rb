class Document < ActiveRecord::Base

  validates_presence_of :key, :title_on_main, :title

  named_scope :published, :conditions => "is_published = true", :order => "created_at"
  named_scope :not_hint, :conditions => "for_main_hint = false", :order => "created_at"

end

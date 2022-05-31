class Item < ActiveRecord::Base

  belongs_to :rss, :counter_cache => true

  named_scope :old, :conditions => {:is_old => true}
  named_scope :fresh, :conditions => {:is_old => false}

end

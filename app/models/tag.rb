class Tag < ActiveRecord::Base

  has_and_belongs_to_many :songs
  #has_many :users, :through => :songs

  named_scope :moods, :conditions => {:is_mood => true}

  def gain_rating
    ttime = self.rating_update + 10.seconds
    if DateTime.now.utc > ttime.utc
      self.update_attribute("rating", self.rating + 1) 
      self.update_attribute("rating_update", DateTime.now.utc)
      return true
    else
      return false
    end
  end

end

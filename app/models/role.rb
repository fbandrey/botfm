class Role < ActiveRecord::Base

  has_and_belongs_to_many :users, :order => "rating DESC"

  validates_presence_of   :title

end

class Sound < ActiveRecord::Base
  
  belongs_to :user, :counter_cache => true

  ITEM_LENGTH = 500
  SOUNDS_BLOCK_LENGTH = 6
  SPEECHPRO_ID = "930ae90a1b9c4936a856f026d10d900d"

  VOICES = ["Anna", "Vladimir", "Maria", "Alexander"]
  VOICES_RUS = ["Анна", "Владимир", "Мария", "Александр"]

end

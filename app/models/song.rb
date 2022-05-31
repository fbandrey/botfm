class Song < ActiveRecord::Base

  has_and_belongs_to_many :tags
  belongs_to :user

  has_attachment  :content_type => ["audio/mpeg"],
                  :max_size     => 10.megabytes,
                  :storage      => :file_system ,
                  :path_prefix  => 'public/uploads/songs'

  # validates the size and content_type attributes according to the current model's options
  def attachment_attributes_valid?
    [:size, :content_type].each do |attr_name|
      enum = attachment_options[attr_name]
      errors.add attr_name, ActiveRecord::Errors.default_error_messages[:inclusion] if !(enum.nil? || enum.include?(send(attr_name)))# && video_content.blank?
      #puts ">>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>> #{errors.inspect}"
    end
  end

  def self.validates_as_attachment
#    validates_presence_of :size, :content_type, :filename, :if => Proc.new {|a| a.video_content.blank?}
    validate              :attachment_attributes_valid?
  end

  validates_as_attachment

  def destroy_file
    filename? ? super : true
  end

  def set_size_from_temp_path
    filename ? super : true
  end

  def process_attachment
    filename ? super : true
  end

end

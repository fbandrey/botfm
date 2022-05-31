class Photo < ActiveRecord::Base

  belongs_to :user

  has_attachment :content_type  => :image,
                 :storage       => :file_system,
                 :max_size      => 3.megabytes,
                 :thumbnails    => {:main => 'crop: 100x100'},
                 :processor     => :Rmagick,
                 :path_prefix   => 'public/uploads/photos'

  validates_as_attachment

  protected  
  # Override image resizing method  
  def resize_image(img, size)  
    # resize_image take size in a number of formats, we just want  
    # Strings in the form of "crop: WxH"  
    if (size.is_a?(String) && size =~ /^crop: (\d*)x(\d*)/i) ||  
        (size.is_a?(Array) && size.first.is_a?(String) &&  
          size.first =~ /^crop: (\d*)x(\d*)/i)  
     img.crop_resized!($1.to_i, $2.to_i)  
      # We need to save the resized image in the same way the  
      # orignal does.  
      self.temp_path = write_to_temp_file(img.to_blob)  
    else  
      super # Otherwise let attachment_fu handle it  
    end
  end
end

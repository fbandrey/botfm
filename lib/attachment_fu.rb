module Technoweenie # :nodoc:
  module AttachmentFu # :nodoc:
    module InstanceMethods
      protected
        def sanitize_filename(filename)
          returning filename.strip do |name|
            # NOTE: File.basename doesn't work right with Windows paths on Unix
            # get only the filename, not the whole path
            name.gsub! /^.*(\\|\/)/, ''
            
            # Finally, replace all non alphanumeric, underscore or periods with underscore
            name.gsub! /[^a-zA-Z0-9\.\-]/, '_'
          end
        end
    end
  end
end

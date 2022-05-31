class Array
  def shuffle!
    #a = self.dup
    #(a.size*10).times {|t| a << a.delete_at(Kernel.rand(a.size))}
    #a
    size.downto(1) { |n| push delete_at(Kernel.rand(n)) }
    self
  end
end


class String 

  # XML escaped version of to_s
  def to_xs
    unpack('U*').map {|n| n.xchr}.join # ASCII, UTF-8
    rescue
      unpack('C*').map {|n| n.xchr}.join # ISO-8859-1, WIN-1252
  end

  def downcase
    self.mb_chars.downcase.to_s
  end

  def upcase
    self.mb_chars.upcase.to_s
  end

  def unescape
    x = self.gsub('"', '\"')
    eval "\"#{x}\""
  end

  def httpize
    self =~ /^http:\/\// ? self : "http://"+self
  end

  def remove_empty_p_tag
    self.gsub(/<p.*?>(&nbsp;| )*<\/p>\r\n/, '').strip_nbsp
  end

  def strip_nbsp
    self.gsub(/<p.*?>( |&nbsp;)+/, '<p>').gsub(/( |&nbsp;)+<\/p>/, '</p>')
  end

  def truncate_to_point(point_count = 2)
    split('.')[0...point_count].join('. ')
  end

  ##############################
  # Работа со временем
  ##############################

  # Из вида 22.10.2008 приводит к 2008-10-22
  def correct_parse
    if self.correct_date? and self.date_through_point?
      words = self.split('.').map &:to_i
      return Date.civil(words[2], words[1], words[0])
    end
    DateTime.parse(self)
  end

  # Из вида 2008-10-22 приводит к 22.10.2008
  def correct_date
    if self.correct_date?
      tmp_array = self.split('-')
      tmp_array[2] + "." + tmp_array[1] + "." + tmp_array[0]
    else
      self
    end
  end

  def correct_date?
    self =~ /^\d\d\.\d\d\.\d{4} \d\d:\d\d$/ || self =~ /^\d\d\.\d\d\.\d{4}$/ || self =~ /^\d{4}-\d\d\-\d\d\ \d\d:\d\d$/ || self =~ /^\d{4}-\d\d\-\d\d$/
  end

  def date_through_point?
    self =~ /^\d\d\.\d\d\.\d{4} \d\d:\d\d$/ || self =~ /^\d\d\.\d\d\.\d{4}$/ 
  end

end


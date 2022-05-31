require 'rexml/parsers/pullparser'
class String
  def truncate_html(len = 30)
   begin
    return self if len >= self.size
    p = REXML::Parsers::BaseParser.new(self)
    tags = []
    new_len = len
    results = ''
    while p.has_next? && new_len > 0
    p_e = p.pull
    case p_e[0]
        when :start_element
            tags.push p_e[1]
            results << "<#{tags.last} #{attrs_to_s(p_e[2])}>"
        when :end_element
            results << "</#{tags.pop}>"
        when :text
            if new_len < p_e[1].length
              results << p_e[1].slice!(0...new_len)
              results << p_e[1].slice(/[^ ]*/)
              new_len = 0
            else
              results << p_e[1].first(new_len)
              new_len -= p_e[1].length
            end
        else
            #results << "<!-- #{p_e.inspect} -->"
            results << ""
        end
    end
    results<<"..."
    tags.reverse.each do |tag|
        results << "</#{tag}>"
    end
   rescue  REXML::ParseException
    results = self
   end
   return results
  end

  def strip_part_of_tags(except = ["a", "b", "p", "strong", "img", "table", "tr", "td", "th", "ul", "li", "ol"])
   begin
    p = REXML::Parsers::BaseParser.new(self)
    tags = []
    results = ''
    while p.has_next?
    p_e = p.pull
    case p_e[0]
	when :start_element
	  if p_e[1] == 'li'
	    except -= ['p']
	  end
	  if except.include?(p_e[1])
            tags.push p_e[1] 
	    if (tags.last == 'ul' || tags.last == 'ol')
	      p_e[2]['id'] = 'text'
	    end
            results << "<#{tags.last} #{attrs_to_s(p_e[2])}>"  
	  end
        when :end_element
	    if p_e[1] == 'li'
	      except.push 'p'
	    end
            results << "</#{tags.pop}>" if except.include?(p_e[1])
        when :text
            results << p_e[1]
        else
            #results << <!-- #{p_e.inspect} -->"
            results << ""
        end
	
    end
    tags.reverse.each do |tag|
        results << "</#{tag}>"
    end
    #results.gsub!(/<!--(.*?)-->/,'')
    results.gsub!(REXML::Parsers::BaseParser::COMMENT_PATTERN, '')
    results.gsub!(/<p\s?>\W*<\/p>/, '')
    results.gsub!(/<p\s?>\s*\&nbsp;\s*<\/p>/, '')
    results.gsub!(/\s+/, ' ')
   rescue  REXML::ParseException
    results = self
   end
   return results.gsub(/<(\/?[^>]*) >/, "<\\1>")
  end
private
  def attrs_to_s(attrs)
    if attrs.empty?
      ''
    else
      attrs.to_a.map { |attr| %{#{attr[0]}="#{attr[1]}"} if attr[0]!="style" && attr[0]!="class" }.join(' ')
    end
  end
end




xml.instruct! :xml, :version=>"1.0", :encoding => "utf-8" 
xml.rss(:version=>"2.0") do
  if @current_rss
    xml.channel do
      xml.title("#{@current_rss.title+"." if @current_rss.title && !@current_rss.title.blank?}bot.fm")
      xml.link((request.host + ":" + request.port.to_s).httpize)
      xml.description("Мега-радио! Все дела...")
      xml.image do
        xml.url((request.host + ":" + request.port.to_s + "/images/radiobot.gif").httpize)
        xml.link((request.host + ":" + request.port.to_s).httpize)
        xml.title("#{@current_rss.title+"." if @current_rss.title && !@current_rss.title.blank?}bot.fm")
      end
      xml.pubDate(Time.zone.now)
      @current_rss.items.fresh.each do |elem|
        xml.item do
            xml.title("bot.fm")
            xml.link((request.host + ":" + request.port.to_s).httpize)
            xml.description(elem.content)
            xml.pubDate(elem.created_at.rfc2822)
            xml.guid((request.host + ":" + request.port.to_s).httpize)
        end
      end
    end
  end
end

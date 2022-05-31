namespace :botfm do

  desc 'Regenerate current rsses'
  task 'update_rsses' => :environment do
    Rss.active.each do |rss|
      # Удаляем "старые" записи
      rss.items.old.each do |item|
        item.destroy
      end

      # MY_LOGGER.debug(">>>>>>>>>>>>>>> Send items <<<<<<<<<<<<<<<<")
      # Отправляем оставшиеся записи
      rss.items.each_with_index do |item, ind|
        # MY_LOGGER.debug("#{ind+1} / #{self.items.size}) --- Starting item ID #{item.id} ---")

        texttext = Iconv.iconv('cp1251', 'utf8', item.content.to_s).to_s
        if mp3_xml = send_text("http://tts.speechpro.com/RssMP3.ashx?text=\"#{texttext}\"&voice=1")
          # MY_LOGGER.debug("Respond body ... OK.")
          if mp3_link = get_mp3_link(mp3_xml)
            # MY_LOGGER.debug("MP3 link ... OK.")
            new_sound = Sound.new(:link => mp3_link, :rss_id => self.id)
            if new_sound.save
              # MY_LOGGER.debug("Sound element ... ID #{new_sound.id} created.")
            else
              # MY_LOGGER.debug("Sound element ... Error!")
            end
          else
            # MY_LOGGER.debug("MP3 link ... Error!")
          end
        else
          # MY_LOGGER.debug("Respond body ... Error!")
        end
        # MY_LOGGER.debug("--- Finished. Item ID #{item.id} ---")
      end

      # Помечаем их как "устаревшие"
      # rss.mark_new_as_old
      my_items = rss.items
      if my_items && my_items.any?
        my_items.all.each do |item|
          item.update_attributes(:is_old => true)
        end
      end
    end
    # Sound.create!(:rss_id => 1, :link => "Automatically created text element. #{DateTime.now}")
  end

  def get_mp3_link(file)
    current_link = nil
    doc = REXML::Document.new(file) if file
    if doc
      begin
        current_link = doc.root.elements[1].elements[7].elements[3].text
      rescue Timeout::Error => e
        puts "Error! Alarm!"
      end
    end
    return current_link
  end

  def send_text(link)
    res = nil
    url = URI.parse(URI.encode(link))
    Net::HTTP.start(url.host, url.port) do |http|
      res = http.request(Net::HTTP::Get.new(url.path+'?'+url.query)).body
    end
    return res
  end

end

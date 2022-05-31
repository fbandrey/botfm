class Rss < ActiveRecord::Base
  
  has_many :items, :dependent => :destroy, :order => 'created_at DESC'
  has_many :sounds, :dependent => :destroy, :order => 'created_at DESC'
  belongs_to :user

  require 'uri'
  named_scope :active, :conditions => "botcast_id IS NOT NULL", :order => "created_at"

#################################################################################

  ###  Отправка записей ###
  def regenerate_me
    # Удаляем "старые" записи
    # self.items.old.each do |item|
    #   item.destroy
    # end

    # Отправляем оставшиеся записи
    self.items.each_with_index do |item, ind|
      MY_LOGGER.debug("#{ind+1} / #{self.items.size}) --- Starting item ID #{item.id} ---")


      texttext = Iconv.iconv('cp1251', 'utf8', item.content.to_s).to_s
      if mp3_xml = send_text("http://tts.speechpro.com/RssMP3.ashx?text=\"#{texttext}\"&voice=1")
        MY_LOGGER.debug("Respond body ... OK.")

        if mp3_link = get_mp3_link(mp3_xml)
          MY_LOGGER.debug("MP3 link ... OK.")

          new_sound = Sound.new(:link => mp3_link, :rss_id => self.id)
          if new_sound.save
            MY_LOGGER.debug("Sound element ... ID #{new_sound.id} created.")
          else
            MY_LOGGER.debug("Sound element ... Error!")
          end

        else
          MY_LOGGER.debug("MP3 link ... Error!")
        end

      else
        MY_LOGGER.debug("Respond body ... Error!")
      end


      MY_LOGGER.debug("--- Finished. Item ID #{item.id} ---")
    end

    # Помечаем их как "устаревшие"
    # self.mark_new_as_old
  end

#################################################################################

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
  
#################################################################################

  ###  Получение записей RSS-ленты  ###
  def get_my_m3u(by_proxy = false, server = '', port = '', login = '', password = '')
    # Получаем новый xml-файл. Если прокси-соединение
    if by_proxy
      file = Rss::connect_proxy('http://podcasts.odiogo.com/' + self.title + '-radiobot-ru/podcasts-xml.php', server, port, login, password)
    else
      file = Rss::connect('http://podcasts.odiogo.com/' + self.title + '-radiobot-ru/podcasts-xml.php')
    end

    # Удаляем имеющиеся
#    self.sounds.each do |sound|
#      if sound.destroy
#      else
#        puts "Не удалось удалить источник ID #{sound.id}!"
#      end
#    end


    # Выбираем данные из xml и создаем новые sounds
    count = 0
    canceled = 0
      doc = REXML::Document.new(file) if file
      if doc
          doc.root.elements[1].elements.each do |element|
              # Создаем новый звуковой элемент
              element.each_element_with_attribute('url') do |enclosure|
                  # Если элемент - аудио ссылка, сохраняем!
                  if enclosure.attributes['type'].to_s == "audio/mpeg"
                      link = enclosure.attributes['url'].to_s
                      new_link = link.gsub("get", "read").gsub(".mp3?", ".php?")
                      if Sound.create(:link => new_link, :rss_id => self.id)
                        count += 1
                      else
                        canceled += 1
                      end
                  else
                  end
              end
          end
      end
    puts "Успешно загружено #{count} ссылок на mp3! Отклонено: #{canceled}!"
    return "Успешно загружено #{count} ссылок на mp3! Отклонено: #{canceled}!"
  end

#################################################################################

  def mark_new_as_old
    self.items.each do |item|
      item.update_attributes(:is_old => true)
    end
  end


  def self.send_ubot_request(email, feed_id)
    if email && !email.blank? && feed_id
# ::Proxy("84.22.141.115", "3128", "fba", "")
      my_request = "http://rpc.odiogo.com/ping/ping.php?method_name=weblogUpdates._regenerate_&email_notification=#{email}&feed_id=#{feed_id}"
      puts "| Sending request to Odiogo.com: #{my_request}"
      url = URI.parse(my_request)
      Net::HTTP.start(url.host, url.port) do |http|
        http.request(Net::HTTP::Get.new(url.path+'?'+url.query)).body
      end
      puts "| Complete!"
    else
      puts "| Error! Have no params."
    end
  end

  # Получение файла через прокси.
  def self.connect_proxy(uri, server, port, log, pass)
    puts ">>>>>>>>>>> PROXY (#{uri}) <<<<<<<<<<<<"
    url = URI.parse(uri)
    begin
      Timeout::timeout(15) do
          Net::HTTP::Proxy(server, port, log, pass).start(url.host) do |http|
            return http.get(url.path+(url.query.blank? ? '' : '?'+url.query)).body
          end
      end
    rescue Timeout::Error => e
      flash[:error] = "Ошибка! Не удалось установить Proxy-соединение!"
      puts            "Ошибка! Не удалось установить Proxy-соединение!"
    end
  end

  # Получение файла через прямое соединение.
  def self.connect(uri)
    puts ">>>>>>>>>>> ПРЯМОЕ (#{uri}) <<<<<<<<<<<<"
    url = URI.parse(uri)
    begin
      Timeout::timeout(15) do
          return Net::HTTP.get(URI.parse(uri))
      end
    rescue Timeout::Error => e
      flash[:error] = "Ошибка! Не удалось установить прямое соединение!"
      puts            "Ошибка! Не удалось установить прямое соединение!"
    end
  end

end

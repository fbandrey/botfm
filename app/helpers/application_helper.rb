module ApplicationHelper

  require "mp3info"

  def mp3_fullname(song = nil)
    if song
      my_artist = my_artist2 = nil
      my_title = my_title2 = nil
      Mp3Info.open(RAILS_ROOT + "/public" + song.public_filename) do |mp3|
        my_title = Iconv.iconv('utf8', 'cp1251', mp3.tag.title).to_s.strip if mp3.tag.title
        my_artist = Iconv.iconv('utf8', 'cp1251', mp3.tag.artist).to_s.strip if mp3.tag.artist
      end

      if my_artist.nil? || my_title.nil? || (my_artist.empty? && my_title.empty?)

        Mp3Info.open(RAILS_ROOT + "/public" + song.public_filename) do |mp3|
          my_title2 = Iconv.iconv('utf8', 'cp1251', mp3.tag2["TIT2"]).to_s.strip if mp3.tag2["TIT2"]
          my_artist2 = Iconv.iconv('utf8', 'cp1251', mp3.tag2["TPE1"]).to_s.strip if mp3.tag2["TPE1"]
        end
        if my_artist2.nil? || my_title2.nil? || (my_artist2.empty? && my_title2.empty?)
          return song.filename
        else
          return "#{my_artist2.nil? ? "Исполнитель" : my_artist2.to_s} — #{my_title2.nil? ? "Нет названия" : my_title2.to_s}"
        end

      else
        return "#{my_artist.nil? ? "Исполнитель" : my_artist.to_s} — #{my_title.nil? ? "Нет названия" : my_title.to_s}"
      end
    end
  end

  def print_flash_message
    if flash[:notice] && !flash[:notice].blank?
      "<div id='dialog_message_notice'><a href='#' onClick='javascript:close_notice();' title='Закрыть сообщение'><div class='close_with_me'>X</div></a>#{flash[:notice]}</div>"
    elsif flash[:errors] && !flash[:errors].blank?
      "<div id='dialog_message_error'><a href='#' onClick='javascript:close_notice();' title='Закрыть сообщение'><div class='close_with_me'>X</div></a>#{flash[:errors]}</div>"
    end
  end

  def crop_text(str, num = 45, add = "...", start_pos = 0)
    if str.mb_chars.size <= num
      return str
    else
      return str.mb_chars.slice(start_pos,num) + add
    end
  end

  def middle_crop(str, side_length = 10)
    if str.mb_chars.size <= side_length * 2
      return str
    else
      res  = str.slice(0,side_length)
      res += "..."
      res += str.slice(str.mb_chars.size - side_length, side_length)
      return res
    end
  end

  def admin_menu(elem = '')
    "<div id='admin_main_menu'>" +
      link_to("DJ's ленты", admin_rsses_path, :class => elem == 'rsses' ? "active" : "") +
      "<br/>" + link_to("Пользователи", people_admin_users_path, :class => elem == 'people' ? "active" : "") +
      "<br/>" + link_to("Теги", admin_tags_path, :class => elem == 'tags' ? "active" : "") +
      "<br/>" + link_to("mp3-файлы", admin_songs_path, :class => elem == 'songs' ? "active" : "") +
      "<br/>" + link_to("Документы", admin_documents_path, :class => elem == 'docs' ? "active" : "") +
      "<div style='clear:both; border-bottom:1px dotted #999; padding:0 0 10px 0; margin:0 0 10px 0;'></div>" +
      link_to("Администрация", admin_users_path, :class => elem == 'users' ? "active" : "") +
    "</div>"
  end

  def footer_info_block
    res = "<div id='lists'><ul>"
    if @top_djs && @top_djs.any?
      res += "<li class='tops'>
          <h4>Популярные боткасты</h4>
          <ol>"
            @top_djs.each do |user|
              res += "<li>#{link_to("DJ #{user.name}", dj_path(user.name))}</li>"
            end
      res += "</ol>
        </li>"
    end

    if @top_tags && @top_tags.any?
      res += "<li class='tops'>
        <h4>Популярные метки</h4>
        <ol>"
          @top_tags.each do |tag|
            res += "<li>#{link_to(tag.name, tag_path(:name => tag.name))}</li>"
          end
      res += "</ol>
        </li>"
    end

    if @last_uploads && @last_uploads.any?
      res += "<li class='tops'>
        <h4>Свежие загрузки</h4>
          <ol style='color: rgb(102, 102, 102);'>"
            @last_uploads.each do |song|
              res += "<li id='last_song_#{song.id}' title='DJ #{song.user.name}'>#{crop_text(mp3_fullname(song), 30) rescue song.filename}</li>"
            end
      res += "</ol>
        </li>"
    end

    if @docs && @docs.any?
      res += "<li class='tops'>
        <h4>Чокаво</h4>
          <ol>"
            @docs.each_with_index do |doc, ind|
              if ind == @docs.size-1
                res += "<li>#{link_to("форум", "http://s109267103.onlinehome.us/ubot/botfm/ru/forum/", :target => "_blank")}</li>"
              end
#                <a href='/#{doc.key}' title='#{doc.title}' onclick='Modalbox.show(this.href, {title: this.title, width: 800}); return false;'>
              res += "<li>
                <a href='/#{doc.key}' title='#{doc.title}'>
                  #{doc.title_on_main}
                </a>
              </li>"
            end
      res += "</ol>
        </li>"
    end

    res += "</ul>
      <div style='clear:both;'></div>
    </div>"

    return res
  end

  def text_field_hooks text, options = {}
    { :onfocus => "if (this.value == '#{text}') {this.value = ''; }",
      :onblur  => "if (this.value == '') {this.value = '#{text}'; }",
      :autocomplete => "off"
    }.merge options
  end

end

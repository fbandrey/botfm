class MainController < BaseController

  before_filter :login_required, :only => [:add_to_rss, :upload, :uploading, :profile, :update_profile, :text_to_voice, :playlist, :delete_song, :delete_sound]
  before_filter :load_footer, :only => [:index]
  access_control [:add_to_rss, :upload, :uploading, :profile, :update_profile, :text_to_voice] => 'user'
  skip_before_filter :verify_authenticity_token, :only => [:play_dj]

  require 'uri'
  include ApplicationHelper

  def send_password
    requested_user = nil
    if params[:login] && !params[:login].blank?
      if requested_user = User.find_by_login(params[:login])
      else
        flash[:errors] = "Пользователь с логином \"#{params[:login]}\" не найден"
      end
    elsif params[:email] && !params[:email].blank?
      if requested_user = User.find_by_email(params[:email])
      else
        flash[:errors] = "Пользователь с почтой \"#{params[:email]}\" не найден"
      end
    else
      flash[:errors] = "Введите свой логин или e-mail"
    end
    
    if requested_user
      new_pass = User.random_password(8)
      if new_pass && requested_user.update_attributes(:password => new_pass, :password_confirmation => new_pass)
        email = RadiobotMailer.create_remind_pass(requested_user, new_pass)
        email.set_content_type("text/html;charset=UTF-8")
        if RadiobotMailer.deliver(email)
          flash[:notice] = 'На почтовый ящик пользователя было отправлено письмо'
        else
          flash[:errors] += 'При отправке письма возникли ошибки'
        end
      else
        flash[:errors] += 'Ошибка восстановления пароля!'
      end
    end

    if flash[:notice]
      redirect_to "/"
    else
      redirect_to :back
    end
  end

  def select_new_dj_tracks(dj_id)
    mass = mass1 = mass2 = []
    # Если слушают "главное" радио
    if dj_id.eql?("main")
      admin_user = User.first(:conditions => "login = 'admin' AND id IN(#{Role.find_by_title("admin").users.map(&:id).join(',')})")
      current_sound_block = admin_user.stop_sounds ? Sound::SOUNDS_BLOCK_LENGTH : (Sound::SOUNDS_BLOCK_LENGTH / 2).to_i
      unless admin_user.stop_sounds
        voice_sounds = Sound.all(:limit => current_sound_block, :order => "RANDOM()")
        voice_sounds.each do |sound|
          mass1 << sound.link+"^voice"
        end
      end
      cur_songs = Song.all(:limit => current_sound_block, :order => "RANDOM()")
      cur_songs.each do |song|
        mass2 << song.public_filename+"^#{mp3_fullname(song)}"
      end
    # Если конкретного диджея
    else
      selected_dj = User.find_by_id(dj_id)
      admin_user = User.first(:conditions => "login = 'admin' AND id IN(#{Role.find_by_title("admin").users.map(&:id).join(',')})")
      current_sound_block = admin_user.stop_sounds ? Sound::SOUNDS_BLOCK_LENGTH : (Sound::SOUNDS_BLOCK_LENGTH / 2).to_i
      # Если слушают диджея
      if selected_dj
        selected_dj.gain_rating
        unless admin_user.stop_sounds
          voice_sounds = Sound.all(:conditions => {:user_id => selected_dj.id}, :limit => current_sound_block, :order => "RANDOM()")
          voice_sounds.each do |sound|
            mass1 << sound.link+"^voice"
          end
        end

        cur_songs = Song.all(:conditions => {:user_id => selected_dj.id}, :limit => current_sound_block, :order => "RANDOM()")
        cur_songs.each do |song|
          mass2 << song.public_filename+"^#{mp3_fullname(song)}"
        end
      end
    end

    (mass1.size+mass2.size).times do |n|
      mass << n.modulo(2).zero? ? mass1.pop : mass2.pop
    end

    # "Тщательно" перемешиваем
    return mass.shuffle!
  end

  def select_new_tag_tracks(tag_id)
    mass = []
    selected_tag = Tag.find_by_id(tag_id.to_i)

    if selected_tag
      selected_tag.gain_rating
      #songs = Song.all(:joins => ["INNER JOIN songs_tags ON songs_tags.song_id = songs.id WHERE songs_tags.tag_id IN (#{cur_tags.join(', ')})"], :order => "RANDOM()")
      songs = selected_tag.songs
      songs.shuffle!
      # Если тег "разговоры" - отдавать текстовые озвучки
      if selected_tag.name.mb_chars.downcase.to_s.eql?("разговоры")
        sounds = Sound.all(:limit => (Sound::SOUNDS_BLOCK_LENGTH / 2).to_i, :order => "RANDOM()")
        songs = songs.slice(0, (Sound::SOUNDS_BLOCK_LENGTH / 2).to_i)

        (sounds.size+songs.size).times do |n|
          if n.modulo(2).zero?
            mass << sounds.pop.link+"^voice" if sounds.any?
          else
            if songs.any?
              tt_song = songs.pop
              mass << tt_song.public_filename+"^#{mp3_fullname(tt_song)}"
            end
          end
        end
        #puts "| Mass: #{mass.inspect}"
      else
        songs = songs.slice!(0, Sound::SOUNDS_BLOCK_LENGTH)
        songs.each do |song|
          mass << song.public_filename+"^#{mp3_fullname(song)}"
        end
      end
    end

    # "Тщательно" перемешиваем еще раз
    return mass.shuffle!
  end

  def index
    session[:fba_dj] = ""
    ids = Role.find_by_title("user") && Role.find_by_title("user").users.any? ? Role.find_by_title("user").users.map(&:id).join(",") : "0"
    @users = User.active.with_content.all(:conditions => "id IN (#{ids})", :order => "rating DESC")
  end

  def get_music
    mass = []
    if params[:dj_id]
      mass = select_new_dj_tracks(params[:dj_id])
    elsif params[:tag_id]
      mass = select_new_tag_tracks(params[:tag_id].to_i)
    end
    render :text => mass.join("|")
  end

  # Добавление записи пользователю
  def add_to_rss
    #@text = crop_text(params[:text].to_s, Sound::ITEM_LENGTH, "")
    @text = params[:text].to_s
    @back_url = params[:url].to_s
    session[:return_to_url] = @back_url if @back_url && !@back_url.blank?

    redirect_to "/" if @text.nil? || @text.blank? # Редирект на главную, если без параметров

    @item = Item.new
  end

  def text_to_voice
    to_client_link = true
    voice = nil
    src_text = params[:text].to_s.mb_chars.slice!(0,Sound::ITEM_LENGTH).to_s
    voice = params[:voice].to_i if [1,2,3,4].include?(params[:voice].to_i)

    if [1,2,3,4].include?(voice)
      if text = Iconv.iconv('cp1251', 'utf8', src_text).to_s
        unless current_user.have_ban
            mp3_xml = send_text("http://81.3.190.190/VitalVoiceWeb/RssMP3.ashx?text=\"#{text}\"&voice=#{Sound::VOICES[voice-1]}&KeyAPI=#{Sound::SPEECHPRO_ID}")
            if mp3_xml
#            if mp3_xml = send_text("http://tts.speechpro.com/RssMP3.ashx?text=\"#{text}\"&voice=#{voice}")
                # MY_LOGGER.debug("Respond body ... OK.")
                if mp3_link = get_mp3_link(mp3_xml)
                    # MY_LOGGER.debug("MP3 link ... OK.")
                    back_link = (session[:return_to_url] && !session[:return_to_url].blank?) ? session[:return_to_url].to_s : nil
                    new_sound = Sound.new(:link => mp3_link, :user_id => current_user.id, :text => src_text, :source_link => back_link)
                    if new_sound.save
                        # MY_LOGGER.debug("Sound element ... ID #{new_sound.id} created.")
                        # flash[:notice] = "Sound element ID #{new_sound.id} created."
                    else
                        # MY_LOGGER.debug("Sound element Error!")
                        flash[:notice] = "При сохранении Вашей последней голосовой записи возникли ошибки!"
                        to_client_link = false
                    end
                else
                  # MY_LOGGER.debug("MP3 link ... Error!")
                end
            else
                # MY_LOGGER.debug("Respond body ... Error!")
              flash[:errors] = 'Ошибка соединения с сервером синтеза речи!'
              to_client_link = false
            end
        else
          flash[:errors] = 'Ваш аккаунт ограничен для добавления записей'
          to_client_link = false
        end
      end
    else
      flash[:errors] = 'Выберите человека для озвучки Вашей новости'
      to_client_link = false
    end

    # Вернуться на прежний(сторонний) сайт, если нужно
    if to_client_link && session[:return_to_url] && !session[:return_to_url].blank?
      redirect_to session[:return_to_url]
    else
      redirect_to "/"
    end
  end

  def registration
    #redirect_to root_url(:subdomain => false) if logged_in?
    redirect_to "/" if logged_in?
    @page_title = "Регистрация"
  end

  # Профиль пользователя
  def profile
    redirect_to "/" if current_user.login.eql?("admin")
    @page_title = "Профиль"
    @user = current_user
    render "main/registration"
  end

  # Обновление профиля
  def update_profile
    @user = current_user
    if @user.update_attributes(params[:user])
      flash[:notice] = "<p>Профиль успешно изменен</p>"

      if params[:photo] && params[:photo][:uploaded_data]
        # Изменяем фото
        @user.photo.destroy if @user.photo
        @photo = Photo.new(params[:photo])
        @photo.user_id = @user.id
        if @photo.save
        else
          flash[:notice] += "<p>Ошибка при сохранении фото!</p>"
        end
      end
    else
      flash[:errors] = 'Ошибка при изменении профиля'
    end
    redirect_to "/"
  end

  # Страница загрузки музыки
  def upload
    @page_title = "Загрузка музыки"
    @song = Song.new

    @tags_moods  = Tag.moods.all(:order => "rating DESC")

    @tags_direct = Tag.all(:order => "rating DESC")
    @tags_direct.delete_if{|t| @tags_moods.include?(t)}
  end

  # Загрузка самих mp3-файлов
  def uploading
    if params[:accept_rules]
      attachments = []
      if params[:files] && params[:files][:uploaded_data] && params[:files][:uploaded_data].any?
        params[:files][:uploaded_data].each_with_index do |el, index|
          attachments << [params[:files][:categories][index], el]
        end

        attachments = attachments.delete_if{|a| a.last.blank?}
        created = 0
        attachments.each do |file|
          begin
            created+=1 if cur_song = Song.create!(:uploaded_data => file.last, :user_id => current_user.id)
            cur_song.tags << Tag.find(file.first)
          rescue ActiveRecord::RecordNotSaved, ActiveRecord::RecordInvalid => er
            logger.error "error - #{er}"
          end
        end
        flash[:notice] = "#{created} из #{attachments.size} файла(ов) загружено"
        flash[:notice] = "Загружен 1 файл" if created == 1
      else
        flash[:notice] = "Загружено 0 файлов"
      end
      redirect_to "/playlist"
    else
      flash[:errors] = "Для загрузки файлов Вам необходимо согласиться с правилами и условиями bot.fm"
      redirect_to "/upload"
    end
  end

  # Мой боткаст
  def playlist
    @page_title = "Боткаст"

    @tags_moods  = Tag.moods.all(:order => "rating DESC")

    @tags_direct = Tag.all(:order => "rating DESC")
    @tags_direct.delete_if{|t| @tags_moods.include?(t)}
  end

  # Удаление песни из боткаста
  def delete_song
    song = Song.find_by_id(params[:id])
    if song && song.user_id == current_user.id
      if song.destroy
        flash[:notice] = "Файл был успешно удален"
      else
        flash[:errors] = "Ошибка при удалении файла!"
      end
    else
      flash[:errors] = "Ошибка! Файл не найден"
    end
    redirect_to "/playlist"
  end

  # Удаление озвучки из боткаста
  def delete_sound
    sound = Sound.find_by_id(params[:id])
    if sound && sound.user_id == current_user.id
      if sound.destroy
        flash[:notice] = "Файл был успешно удален"
      else
        flash[:errors] = "Ошибка при удалении файла!"
      end
    else
      flash[:errors] = "Ошибка! Файл не найден"
    end
    redirect_to "/playlist"
  end

  # Регистрация
  def create_user
    @user = User.new(params[:user])
    my_password = params[:user][:password].to_s

    # Переводим логин в нижний регистр
    @user.login = params[:user][:login].to_s.downcase

    if @user.save
      @user.roles << Role.find_by_title('user')
      flash[:notice] = "<p>Вы успешно зарегистрировались!</p>"

      if params[:photo] && params[:photo][:uploaded_data]
        @photo = Photo.new(params[:photo])
        @photo.user_id = @user.id
        if @photo.save
        else
          flash[:errors] += "<p>Ошибка при сохранении фото!</p>"
          @user.errors.merge!({"photo" => ["Выберите фотографию"]})
        end
      end

      email = RadiobotMailer.create_custom_mail(@user, my_password)
      email.set_content_type("text/html;charset=UTF-8")
      if RadiobotMailer.deliver(email)
        flash[:notice] += '<p>На Ваш e-mail отправлено письмо с подтверждением</p>'
      else
        flash[:notice] += '<p>При отправке письма на Ваш e-mail возникли ошибки</p>'
      end

      redirect_to "/"
    else
      flash[:errors] = ""
      @user.errors.each_full do |msg|
        mass = msg.split("|")
        flash[:errors] += "<p>#{mass.last}</p>"
      end
      render :action => "registration"
    end
  end

  private

  #####################################################################

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
    begin
      url = URI.parse(URI.encode(link))
      Net::HTTP.start(url.host, url.port) do |http|
        res = http.request(Net::HTTP::Get.new(url.path+'?'+url.query)).body
      end
      return res
    rescue
      return nil
    end
  end

end

class TagsController < BaseController

  before_filter :login_required, :only => [:change_tag]
  before_filter :load_footer, :only => [:show]
  access_control [:change_tag] => 'user'

  def show
    @tag = Tag.find_by_name(params[:name])
    if @tag
      @page_title = "Метка «#{@tag.name}»"

      ids = @tag.songs.map(&:user_id).compact.uniq
      @tag_users = ids.any? ? User.all(:conditions => "id IN(#{ids.join(',')})", :order => "rating DESC") : []
    else
      flash[:errors] = "Ошибка! Тег не найден"
      redirect_to "/"
    end
  end

  def change_tag
    addict = ""
    if params[:tag] && params[:song]
      song = Song.find_by_id(params[:song].to_i)
      tag = Tag.find_by_id(params[:tag].to_i)
      if tag && song && song.user_id == current_user.id
        song.tags = [tag]
        flash[:notice] = "Тег успешно изменен"
        addict = "#song_#{song.id}"
      else
        flash[:errors] = "Ошибка при изменении тега"
      end
    else
      flash[:errors] = "Ошибка при изменении тега"
    end

    redirect_to "/playlist#{addict}"
  end

end

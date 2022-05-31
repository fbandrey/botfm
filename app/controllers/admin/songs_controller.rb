class Admin::SongsController < Admin::BaseController

  access_control :DEFAULT => 'admin|editor'

  def index
    @songs = Song.all
  end

  def destroy
    @song = Song.find(params[:id])
    if @song.destroy
      flash[:notice] = "mp3-файл удален"
    else
      flash[:error] = "Ошибка при удалении mp3-файла"
    end
    redirect_to admin_songs_path
  end

end

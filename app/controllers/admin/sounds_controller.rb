class Admin::SoundsController < Admin::BaseController

  access_control :DEFAULT => 'admin|editor'

  def destroy
    @sound = Sound.find(params[:id])
    if @sound.destroy
      flash[:notice] = 'Звуковая запись удалена.'
    else
      flash[:error] = 'Ошибка при удалении звуковой записи.'
    end
    redirect_to :back
  end

end

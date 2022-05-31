class Admin::ItemsController < Admin::BaseController

  access_control :DEFAULT => 'admin|editor'

  def destroy
    @item = Item.find(params[:id])
    if @item.destroy
      flash[:notice] = 'Запись удалена.'
    else
      flash[:error] = 'Ошибка при удалении записи.'
    end
    redirect_to :back
  end

end

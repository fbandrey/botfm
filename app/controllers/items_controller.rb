class ItemsController < BaseController

  include ApplicationHelper
  access_control [:create] => 'user'

  def create
    unless current_user.have_ban
      @item = Item.new(params[:item])
      if @item.save

      else
        flash[:errors] = 'Item create error!'
      end
      #@item.rss_id = current_user.rss.id
      #@item.content = crop_text(@item.content, Rss::ITEM_LENGTH)

    else
      flash[:errors] = 'Ваш аккаунт ограничен для добавления записей.'
    end
    redirect_to :back
  end

  private


end

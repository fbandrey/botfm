class Admin::RssesController < Admin::BaseController

  access_control :DEFAULT => 'admin|editor'

  def index
    ids = Role.find_by_title("user") && Role.find_by_title("user").users.any? ? Role.find_by_title("user").users.map(&:id).join(",") : "0"
    @users = User.all(:conditions => "id IN (#{ids})", :order => "rating DESC")
  end

  def show
    @user = User.find(params[:id])
  end

#  def new
#    @rss = Rss.new
#  end

#  def all_items_is_old
#    rss = Rss.find(params[:id])
#    rss.mark_new_as_old
#    redirect_to :back
#  end

#  def create
#    @rss = Rss.new(params[:rss])
#
#    if @rss.save
#      flash[:notice] = 'Новая RSS-лента создана.'
#    else
#      flash[:error] = 'Ошибка при добавлении RSS-ленты.'
#    end
#    redirect_to admin_rsses_path
#  end

  def update
    @rss = Rss.find(params[:id])

    if @rss.update_attributes(params[:rss])
      flash[:notice] = 'RSS-лента изменена.'
    else
      flash[:error] = 'Ошибка при редактировании RSS-ленты.'
    end
    redirect_to admin_rsses_path
  end

  def destroy
    @rss = Rss.find(params[:id])
    if @rss.destroy
      flash[:notice] = 'RSS-лента удалена.'
    else
      flash[:error] = 'Ошибка при удалении RSS-ленты.'
    end
    redirect_to admin_rsses_path
  end

end

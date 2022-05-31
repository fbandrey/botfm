class Admin::TagsController < Admin::BaseController

  access_control :DEFAULT => 'admin|editor'

  def index
    @tags = Tag.find(:all, :order => 'rating DESC')
  end

  def show
    @tag = Tag.find(params[:id])
  end

  def new
    @tag = Tag.new
  end

  def edit
    @tag = Tag.find(params[:id])
  end

  def create
    @tag = Tag.new(params[:tag])

    if @tag.save
      flash[:notice] = "Новый тег \"#{@tag.name}\" создан."
    else
      flash[:error] = 'Ошибка при добавлении тега.'
    end
    redirect_to admin_tags_path
  end

  def update
    @tag = Tag.find(params[:id])

    if @tag.update_attributes(params[:tag])
      flash[:notice] = "Тег \"#{@tag.name}\" изменен"
    else
      flash[:error] = 'Ошибка при редактировании тега'
    end
    redirect_to admin_tags_path
  end

  def destroy
    @tag = Tag.find(params[:id])
    name = @tag.name
    if @tag.destroy
      flash[:notice] = "Тег \"#{name}\" удалена"
    else
      flash[:error] = "Ошибка при удалении тега"
    end
    redirect_to admin_tags_path
  end

end

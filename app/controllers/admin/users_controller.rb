class Admin::UsersController < Admin::BaseController

  access_control [:new, :create, :destroy, :toggle_soungs] => 'admin' 
  access_control [:index, :edit, :update, :people] => 'admin|editor' 

  def index
    @users = Role.find_by_title('admin').users + Role.find_by_title('editor').users
  end

  def toggle_soungs
    admin_user = User.first(:conditions => "login = 'admin' AND id IN(#{Role.find_by_title("admin").users.map(&:id).join(',')})")
    if admin_user
      admin_user.update_attribute("stop_sounds", !admin_user.stop_sounds)
    end
    redirect_to :back
  end

  def people
    @users = Role.find_by_title('user').users
  end

  def new
    @user = User.new
  end

  def edit
    @user = User.find(params[:id])
    @roles = @user.roles
  end

  def create
    @user = User.new(params[:user])
    @user.save!

    @user.roles << Role.find_by_title('admin') if params[:user][:is_admin].to_i > 0

    flash[:notice] = "Новый пользователь зарегистрирован!"
    redirect_to admin_users_path
  rescue ActiveRecord::RecordInvalid
    render :action => 'new'
  end

  def update
    @user = User.find(params[:id])

    if @user.update_attributes(params[:user])
      @user.roles = @user.roles - [Role.find_by_title('admin')]
      @user.roles << Role.find_by_title('admin') if params[:user][:is_admin].to_i > 0

      flash[:notice] = 'Пользователь изменен'
    else
      flash[:errors] = ""
      @user.errors.each_full do |msg|
        mass = msg.split("|")
        flash[:errors] += "<p>#{mass.last}</p>"
      end
    end

    if @user.roles.include?(Role.find_by_title('admin')) || @user.roles.include?(Role.find_by_title('editor'))
      redirect_to admin_users_path
    else
      redirect_to people_admin_users_path
    end
  end

  def destroy
    user = User.find(params[:id])
    if user.destroy
      flash[:notice] = "Пользователь удалён"
    else
      flash[:errors] = "Ошибка при удалении пользователя!"
    end

    redirect_to :back
  end

end

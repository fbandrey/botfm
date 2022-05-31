class DjsController < BaseController

  before_filter :load_footer, :only => [:show]

  def show
    @active_dj = User.find_by_name(params[:name])
    session[:fba_dj] = ""
    ids = Role.find_by_title("user") && Role.find_by_title("user").users.any? ? Role.find_by_title("user").users.map(&:id).join(",") : "0"
    @users = User.active.with_content.all(:conditions => "id IN (#{ids})", :order => "rating DESC")

    render :template => "main/index"
  end

end

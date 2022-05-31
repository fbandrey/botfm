# This controller handles the login/logout function of the site.  
class Admin::SessionsController < Admin::BaseController
  # Be sure to include AuthenticationSystem in Application Controller instead
  skip_before_filter :login_required, :only => [:new, :create]

  before_filter :session_cleanup, :only => [:create]

  def new
  end

  def create
    self.current_user = User.authenticate(params[:login], params[:password])
    if logged_in? && (permit?('admin') || permit?('editor'))
#      if params[:remember_me] == "1"
#        self.current_user.remember_me
#        cookies[:auth_token] = { :value => self.current_user.remember_token , :expires => self.current_user.remember_token_expires_at }
#      end
      flash[:notice] = "Авторизация успешно пройдена"
      redirect_to '/admin'
    else
      self.current_user.forget_me if logged_in?
      cookies.delete :auth_token
      reset_session
      flash[:error] = "Логин или пароль введены неверно!"
      redirect_to "/admin"
    end
  end

  def destroy
    self.current_user.forget_me if logged_in?
    cookies.delete :auth_token
    reset_session
    flash[:notice] = "Вы успешно вышли из системы."
    redirect_back_or_default('/admin')
  end

  private

  def session_cleanup
    backup = session.data.clone
    reset_session
    backup.each { |k, v| session[k] = v unless k.is_a?(String) && k =~ /^as:/ }
  end 

end

# This controller handles the login/logout function of the site.  
class SessionsController < BaseController
  # Be sure to include AuthenticationSystem in Application Controller instead

  before_filter :session_cleanup, :only => [:create]

  def new
  end

  def create
    user = User.first(:conditions => ['login = ?', params[:login]])
    if user
      self.current_user = User.authenticate(params[:login], params[:password])
    end

    if logged_in? && permit?('user')
      current_user.gain_rating
      flash[:notice] = "Добро пожаловать на bot.fm!"
      # После авторизации перейти по нужной ссылке, если она была
      if session[:return_to] && !session[:return_to].blank?
        url = session[:return_to].to_s
        session[:return_to] = ''
        redirect_to url
      else
        redirect_to "/"
      end
    else
      # Запоминаем ссылки "назначения" и "возврата"
      my_link_url = session[:return_to] ? session[:return_to].to_s : ""
      site_link_url = session[:return_to_url] ? session[:return_to_url].to_s : ""

      self.current_user.forget_me if logged_in?
      cookies.delete :auth_token
      reset_session

      # Записываем ссылки заного
      session[:return_to] = my_link_url
      session[:return_to_url] = site_link_url

      flash[:errors] = "Неверный логин или пароль"
      redirect_to "/"
    end
  end

  def destroy
    self.current_user.forget_me if logged_in?
    cookies.delete :auth_token
    reset_session
    flash[:notice] = "Всего хорошего, до скорых встреч в эфире! :)"
    redirect_back_or_default('/')
  end

  private

  def session_cleanup
    backup = session.data.clone
    reset_session
    backup.each { |k, v| session[k] = v unless k.is_a?(String) && k =~ /^as:/ }
  end 

end

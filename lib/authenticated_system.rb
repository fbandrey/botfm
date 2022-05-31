module AuthenticatedSystem
  protected
    def logged_in?
      current_user != :false
    end
    
    def current_user
      @current_user ||= (login_from_session || login_from_basic_auth || login_from_cookie || :false)
    end
    
    def current_user=(new_user)
      session[:user] = (new_user.nil? || new_user.is_a?(Symbol)) ? nil : new_user.id
      @current_user = new_user
    end
    
    def authorized?
      logged_in?
    end

    def login_required
#      puts ">>>>>>>>>>> |SESSION| >>>>>>>>>>>> #{session.inspect}"
      authorized? || access_denied
    end

    def check_role(role)
      unless logged_in? && @current_user.has_role?(role)
        if logged_in?
          permission_denied
        else
          store_referer
          access_denied
        end
     end
    end

    def access_denied
      respond_to do |accepts|
        accepts.html do
          store_location
          # Если хотят попасть в админку
          if session[:return_to].to_s.scan('admin').any?
#            flash[:errors] = session[:return_to]
            redirect_to :controller => '/admin/sessions', :action => 'new'
          else
            flash[:errors] = "Для продолжения работы, пожалуйста, авторизуйтесь!"
            session[:return_to_url] = params[:url]
            redirect_to '/?authorize=1#authorize_form'
          end
        end
        accepts.xml do
          headers["Status"]           = "Unauthorized"
          headers["WWW-Authenticate"] = %(Basic realm="Web Password")
          render :text => "Could't authenticate you", :status => '401 Unauthorized'
        end
      end
      false
    end  
    
    # Store the URI of the current request in the session.
    # We can return to this location by calling #redirect_back_or_default.
    def store_location
      session[:return_to] = request.request_uri
    end
    
    # Redirect to the URI stored by the most recent store_location call or
    # to the passed default.
    def redirect_back_or_default(default)
      session[:return_to] ? redirect_to(session[:return_to]) : redirect_to(default)
      session[:return_to] = nil
    end
    
    # Inclusion hook to make #current_user and #logged_in?
    # available as ActionView helper methods.
    def self.included(base)
      base.send :helper_method, :current_user, :logged_in?
    end

    # Called from #current_user.  First attempt to login by the user id stored in the session.
    def login_from_session
      self.current_user = User.find_by_id(session[:user]) if session[:user]
    end

    # Called from #current_user.  Now, attempt to login by basic authentication information.
    def login_from_basic_auth
      username, passwd = get_auth_data
      self.current_user = User.authenticate(username, passwd) if username && passwd
    end

    # Called from #current_user.  Finaly, attempt to login by an expiring token in the cookie.
    def login_from_cookie      
      user = cookies[:auth_token] && User.find_by_remember_token(cookies[:auth_token])
      if user && user.remember_token?
        user.remember_me
        cookies[:auth_token] = { :value => user.remember_token, :expires => user.remember_token_expires_at }
        self.current_user = user
      end
    end

  private
    @@http_auth_headers = %w(X-HTTP_AUTHORIZATION HTTP_AUTHORIZATION Authorization)
    # gets BASIC auth info
    def get_auth_data
      auth_key  = @@http_auth_headers.detect { |h| request.env.has_key?(h) }
      auth_data = request.env[auth_key].to_s.split unless auth_key.blank?
      return auth_data && auth_data[0] == 'Basic' ? Base64.decode64(auth_data[1]).split(':')[0..1] : [nil, nil] 
    end
end

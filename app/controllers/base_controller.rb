class BaseController < ApplicationController
  layout 'main'
  include AuthenticatedSystem

  protected  
    
  # Will either fetch the current account or return nil if none is found  
#  def current_account  
#    @account ||= User.find_by_subdomain(current_subdomain)  
#  end  

  # Make this method visible to views as well  
#  helper_method :current_account  

  # This is a before_filter we'll use in other controllers  
#  def account_required  
#    unless current_account  
#      flash[:errors] = "Пользователь '#{current_subdomain}' не найден!"  
#      redirect_to :controller => "main", :action => "index", :subdomain => false  
#    end  
#  end  

  def load_footer
    ids = Role.find_by_title("user") && Role.find_by_title("user").users.any? ? Role.find_by_title("user").users.map(&:id).join(",") : "0"
    @top_djs = User.active.with_content.all(:conditions => "id IN (#{ids})", :order => "rating DESC", :limit => 5)
    @top_tags = Tag.all(:order => "rating DESC", :limit => 5)
    @last_uploads = Song.all(:order => "created_at DESC", :limit => 5)
    @docs = Document.published.not_hint.all
  end

end

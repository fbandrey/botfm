class RssesController < BaseController

  #before_filter :load_rss

  def show
    @current_rss = Rss.find_by_id(params[:id])
    respond_to do |format|
      format.xml  { render :rss => @current_rss }
    end
  end

  private

  def load_rss
    #@current_rss = Rss.find_by_subdomain(current_subdomain)
    #if @current_rss.nil? || current_subdomain.eql?('admin')
    #  flash[:error] = "Invalid RSS"
    #  #redirect_to main_index_path(:subdomain => nil)
    #  redirect_to root_url(:subdomain => false)
    #end
  end

end

ActionController::Routing::Routes.draw do |map|
 
  map.resources   :items
  map.resources   :main,
                  :collection => {:add_to_rss => :post, :registration => :get, :create_user => :post, :upload => :get, :uploading => :post, :play_dj => :post, :stop_dj => :post, :get_music => :get, :profile => :get, :update_profile => :post, :text_to_voice => :get, :remind => :get, :send_password => :post, :playlist => :get, :delete_song => :get, :delete_sound => :get}

  map.resource   :session,
                 :collection => {:destroy => :get}

  map.resources  :rsses
  map.resources  :documents
  map.resources  :tags,
                 :collection => {:change_tag => :get}

  map.namespace :admin do |admin|
    admin.root       :controller => "rsses", :action => "index"

    admin.resource   :session
    admin.resources  :users,
                     :collection => {:people => :get, :toggle_soungs => :get}

    admin.resources  :rsses,
                     :member => {:all_items_is_old => :get}
    admin.resources  :items
    admin.resources  :sounds
    admin.resources  :tags
    admin.resources  :documents
    admin.resources  :songs
  end

#  map.rss_root "", :controller => "rsses", :action => "show", :conditions => {:subdomain => /.+/}
  map.root :controller => 'main', :action => 'index'

#  map.connect '/rss/:id', :controller => 'rsses', :action => 'show', :format => 'xml'
#  map.connect '/tag/:id', :controller => 'tags', :action => 'show'
  map.dj      '/dj/:name', :controller => 'djs', :action => 'show'
  map.connect '/profile', :controller => 'main', :action => 'profile'
  map.connect '/playlist', :controller => 'main', :action => 'playlist'
  map.connect '/remind', :controller => 'main', :action => 'remind'
  map.connect '/upload', :controller => 'main', :action => 'upload'
  map.connect '/registration', :controller => 'main', :action => 'registration'
  map.connect '/add_to_rss', :controller => 'main', :action => 'add_to_rss'
  map.connect ':controller/:action/:id'
  map.connect ':controller/:action/:id.:format'

  map.tag '/tag/:name', :controller => 'tags', :action => 'show'
  map.connect '*path', :controller => 'documents', :action => 'show'
end

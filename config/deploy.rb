set :application, "botfm"
set :repository,  "ssh://hosting_radiobot@hydrogen.locum.ru/home/hosting_radiobot/botfm.git"

dpath = "/home/hosting_radiobot/projects/bot-fm"

set :user, "hosting_radiobot"
set :use_sudo, false
set :deploy_to, dpath

set :deploy_via, :copy
set :copy_strategy, :export

set :scm, :git

set :rake, "/var/lib/gems/1.8/bin/rake"

role :web, "hydrogen.locum.ru"                   # Your HTTP server, Apache/etc
role :app, "hydrogen.locum.ru"                   # This may be the same as your `Web` server
role :db,  "hydrogen.locum.ru", :primary => true # This is where Rails migrations will run

after "deploy:update_code", :relink_database_yml, :relink_uploads
#:copy_database_config

task :relink_database_yml, roles => :app do
  run "ln -sf #{shared_path}/config/database.yml #{release_path}/config/database.yml"
  # And create symlink on css file
  run "ln -sf #{shared_path}/public/stylesheets/bot.css #{release_path}/public/stylesheets/bot.css"
end

task :relink_uploads, roles => :app do
  run "ln -nfs #{shared_path}/public/uploads #{release_path}/public/uploads"
end

#task :copy_database_config, roles => :app do
#  db_config = "#{shared_path}/config/database.yml"
#  run "cp #{db_config} #{release_path}/config/database.yml"
#end

namespace :deploy do
  task :start do ; end
  task :stop do ; end
  task :restart, :roles => :app, :except => { :no_release => true } do
    run "#{try_sudo} touch #{File.join(current_path,'tmp','restart.txt')}"
  end
end


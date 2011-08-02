set :environment, (ENV['target'] || 'staging')

# Change repo and domain for your setup
if environment == 'production'
  set :domain, 'belushi.sunlightlabs.org'
else
  set :domain, 'hammond.sunlightlabs.org'
end
set :repository, "git://github.com/sunlightlabs/congrelate.git"

set :user, 'congrelate'
set :branch, 'master'
set :application, "congrelate_#{environment}"

# Number of thin processes
set :instances, 2

set :scm, :git
set :deploy_to, "/home/congrelate/www/#{application}"
set :deploy_via, :remote_cache
set :runner, user
set :admin_runner, runner

role :app, domain
role :web, domain

namespace :deploy do  
  desc "Start the server"
  task :start, :roles => [:web, :app] do
    run "cd #{deploy_to}/current && nohup thin -s #{instances} -C config/thin_#{environment}.yml -R config/thin_#{environment}.ru start"
  end
 
  desc "Stop the server"
  task :stop, :roles => [:web, :app] do
    run "cd #{deploy_to}/current && nohup thin -s #{instances} -C config/thin_#{environment}.yml -R config/thin_#{environment}.ru stop"
  end
  
  desc "Restart the server"
  task :restart, :roles => [:web, :app] do
    deploy.stop
    deploy.start
  end
  
  desc "Migrate the database"
  task :migrate, :roles => [:web, :app] do
    run "cd #{deploy_to}/current && rake db:migrate RACK_ENV=#{environment}"
  end
  
  desc "Get shared files into position"
  task :after_update_code, :roles => [:web, :app] do
    run "ln -nfs #{shared_path}/database.yml #{release_path}/config/database.yml"
    run "ln -nfs #{shared_path}/api_keys.yml #{release_path}/sources/api_keys.yml"
  end
  
  desc "Initial deploy"
  task :cold do
    deploy.update
    deploy.start
  end
end

namespace :sources do
  desc "Load in sources.yml and restart the server"
  task :load_sources, :roles => [:web, :app] do
    run "cd #{deploy_to}/current && rake sources:load RACK_ENV=#{environment}"
    deploy.restart
  end
  
  desc "Updates stale sources, SOURCE=keyword to force one."
  task :update, :roles => [:web, :app] do
    set :source, ENV['SOURCE']
    run "cd #{deploy_to}/current && rake sources:update RACK_ENV=#{environment} #{"SOURCE=#{source}" if source}"
  end
end
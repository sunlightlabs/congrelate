set :environment, 'production' # (ENV['target'] || 'staging')

# Change repo and domain for your setup
# if environment == 'production'
  set :domain, 'belushi.sunlightlabs.org'
# else
#   set :domain, 'hammond.sunlightlabs.org'
# end
  
set :repository, "git://github.com/sunlightlabs/congrelate.git"

set :user, 'congrelate'
set :branch, 'master'
set :application, "congrelate_#{environment}"


set :sock, "#{user}.sock"
set :gem_bin, "/home/#{user}/.gem/ruby/1.8/bin"


set :scm, :git
set :deploy_to, "/home/congrelate/www/#{application}"
set :deploy_via, :remote_cache
set :runner, user
set :admin_runner, runner

set :use_sudo, false

role :app, domain
role :web, domain

after "deploy", "deploy:cleanup"
after "deploy:update_code", "deploy:bundle_install"
after "deploy:update_code", "deploy:shared_links"

namespace :deploy do
  
  task :start do
    run "cd #{current_path} && #{gem_bin}/unicorn -D -l #{shared_path}/#{sock} -c #{current_path}/unicorn.rb"
  end
  
  task :stop do
    run "kill `cat #{shared_path}/unicorn.pid`"
  end
  
  task :migrate do; end
  
  desc "Restart the server"
  task :restart, :roles => :app, :except => {:no_release => true} do
    run "kill -HUP `cat #{shared_path}/unicorn.pid`"
  end
  
  desc "Migrate the database"
  task :migrate, :roles => [:web, :app] do
    run "cd #{deploy_to}/current && rake db:migrate RACK_ENV=#{environment}"
  end
  
  desc "Get shared files into position"
  task :shared_links, :roles => [:web, :app] do
    run "ln -nfs #{shared_path}/database.yml #{release_path}/config/database.yml"
    run "ln -nfs #{shared_path}/api_keys.yml #{release_path}/sources/api_keys.yml"
    run "ln -nfs #{shared_path}/config.ru #{release_path}/config.ru"
    run "ln -nfs #{shared_path}/unicorn.rb #{release_path}/unicorn.rb"
  end
  
  desc "Initial deploy"
  task :cold do
    deploy.update
    deploy.start
  end
  
  desc "Install Ruby gems"
  task :bundle_install, :roles => :app, :except => {:no_release => true} do
    run "cd #{release_path} && #{gem_bin}/bundle install --local"
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
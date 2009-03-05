# Capistrano file for Sinatra adapted from Maxim Chernyak
# http://mediumexposure.com/techblog/how-i-setup-sinatra-rake-thin-server-and-deployed-it-capistrano-github

set :application, 'bigsheet_staging'
set :rails_env, 'staging'
set :branch, 'master'

set :user, 'bigsheet'
 
set :scm, :git
 
set :repository, "git@github.com:sunlightlabs/bigsheet.git"
 
set :deploy_to, "/home/bigsheet/#{application}" # path to app on remote machine
set :deploy_via, :remote_cache # quicker checkouts from github
 
set :domain, 'monkey.sunlightlabs.com' # your remote machine's domain name goes here
role :app, domain
role :web, domain
 
set :runner, user
set :admin_runner, runner
 
namespace :deploy do
  task :start, :roles => [:web, :app] do
    run "cd #{deploy_to}/current && nohup thin -C thin_#{environment}.yml -R config.ru start"
  end
 
  task :stop, :roles => [:web, :app] do
    run "cd #{deploy_to}/current && nohup thin -C thin_#{environment}.yml -R config.ru stop"
  end
 
  task :restart, :roles => [:web, :app] do
    deploy.stop
    deploy.start
  end
 
  # This will make sure that Capistrano doesn't try to run rake:migrate (this is not a Rails project!)
  task :cold do
    deploy.update
    deploy.start
  end
end
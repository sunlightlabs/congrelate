namespace :db do
  desc "Migrate the database"
  task(:migrate => :environment) do
    ActiveRecord::Base.logger = Logger.new(STDOUT)
    ActiveRecord::Migration.verbose = true
    ActiveRecord::Migrator.migrate 'db', (ENV['VERSION'] ? ENV['VERSION'].to_i : nil)
  end
end

desc "Loads environment"
task :environment do
  require 'bigsheet'
end
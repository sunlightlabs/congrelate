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
  require 'environment'
end

namespace :sources do
  desc "Load in sources"
  task(:load => :environment) do
    require 'active_record/fixtures'
    Fixtures.create_fixtures('.', File.basename("sources.yml", '.*'))
  end
end
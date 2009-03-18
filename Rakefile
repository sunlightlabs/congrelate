namespace :db do
  desc "Migrate the database"
  task :migrate => :environment do
    ActiveRecord::Base.logger = Logger.new(STDOUT)
    ActiveRecord::Migration.verbose = true
    ActiveRecord::Migrator.migrate 'db', (ENV['VERSION'] ? ENV['VERSION'].to_i : nil)
  end
end

desc "Loads environment"
task :environment do
  require 'environment'
  load_models
end

namespace :sources do
  desc "Load in sources"
  task :load => :environment do
    puts "Loading sources..."
    require 'active_record/fixtures'
    Fixtures.create_fixtures('.', File.basename("sources.yml", '.*'))
  end
  
  desc "Update each source whose TTL has expired"
  task :update => "sources:load" do
    keyword = !ENV['SOURCE'].blank? ? ENV['SOURCE'].tableize.singularize : nil
    if keyword and source = Source.find_by_keyword(keyword)
      update_source source
    else
      Source.all.each do |source|
        last_update = Update.first :conditions => {:source => source.keyword, :status => 'SUCCESS'}, :order => 'created_at DESC'
        if last_update.nil? or ((Time.now - last_update.created_at) > (source.ttl - 1).days)
          update_source source
        else
          puts "[#{source.name}] Up to date, not updating."
        end
      end
    end
  end
end

def update_source(source)
  start_time = Time.now.to_i
  status, message = source.keyword.camelize.constantize.update
  end_time = Time.now.to_i
  puts "[#{source.name}] #{status} - #{message}"
  Update.create! :status => status, 
    :message => message, 
    :source => source.keyword, 
    :elapsed_time => (end_time - start_time)
end
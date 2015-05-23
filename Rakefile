$LOAD_PATH << "lib"
require 'resque/tasks'
require 'sinatra/activerecord/rake'

begin
  require "dotenv"
  Dotenv.load
rescue LoadError
end

namespace :resque do
  task :setup do
    require 'branchinator/jobs'
  end
end

namespace :db do
  task :load_config do
    require_relative "app/env"
  end
end

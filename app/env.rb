require "uri"
require "resque"
require "active_record"
require_relative "models"

module Branchinator
  Resque.redis = Redis.new
  
  begin
    db = URI.parse(ENV['DATABASE_URL'])
    ActiveRecord::Base.establish_connection(
      adapter: case db.scheme
               when "mysql" then "mysql2"
               when "postgres" then "postgresql"
               else db.scheme
               end,
      host: db.host,
      username: db.user,
      password: db.password,
      database: db.path[1..-1],
      encoding: "utf8",
      pool: 20,
      reconnect: true
    )
  end
end
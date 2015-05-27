require "uri"
require "resque"
require "fileutils"
require "active_record"
require_relative "models"

module Branchinator
  Resque.redis = Redis.new(url: ENV['REDIS_URL'])
  
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

  begin
    available_keys = `ssh-add -l`.split("\n").map { |l|
      l.match(/^\d* ([0-9a-f:]+) $/) ? $1 : nil
    }.compact

    if !available_keys.include?(ENV['DEPLOY_KEY_FINGERPRINT'])
      puts "Private key fingerprint not present in ssh agent"

      key_file = File.expand_path("~/.ssh/branchinator_id_rsa")
      if !File.exist?(key_file)
        puts "Private key file not present"
        raise "No private key variable to write" unless ENV['DEPLOY_KEY_PRIVATE']
        FileUtils.mkdir_p(File.dirname(key_file))
        open(key_file, "w") do |k|
          k.puts "-----BEGIN RSA PRIVATE KEY-----"
          k.puts ENV['DEPLOY_KEY_PRIVATE']
          k.puts "-----END RSA PRIVATE KEY-----"
        end
        open("#{key_file}.pub", "w") do |k|
          k.puts ENV['DEPLOY_KEY_PUBLIC']
        end
        puts "Private key written to #{key_file}[.pub]"
      end
    end
  end
end
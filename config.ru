$LOAD_PATH << "app"
$LOAD_PATH << "lib"
require "webapp"
require "resque/server"

if ENV['RESQUE_PASSWORD']
  Resque::Server.use Rack::Auth::Basic do |_u, p|
    p == ENV['RESQUE_PASSWORD']
  end
end

run Rack::URLMap.new(
  "/"            => Branchinator::WebApp,
  "/admin/resque" => Resque::Server.new
 )
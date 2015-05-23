require "sinatra/base"
require "sinatra/activerecord"
require "omniauth"
require "omniauth-github"
require "omniauth-heroku"
require_relative "models"
require_relative "env"

module Branchinator
  class WebApp < Sinatra::Base
    register Sinatra::ActiveRecordExtension

    use Rack::Session::Cookie
    use OmniAuth::Builder do
      provider :github, ENV['GITHUB_KEY'], ENV['GITHUB_SECRET']
    end

    configure do
      set :resque, Resque
    end
  end
end

require_relative "webap_hooks"
require_relative "webap_user"
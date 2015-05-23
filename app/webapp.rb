require "sinatra/base"
require "resque"
require "branchinator/jobs"
require "branchinator/services/github"
require "branchinator/services/heroku"

module Branchinator
  class WebApp < Sinatra::Base
    configure do
      Resque.redis = Redis.new
      set :resque, Resque
    end

    post "/hooks/github" do
      request.body.rewind
      
      github = Services::Github.new(
        env['HTTP_X_GITHUB_EVENT'],
        request.body.read,
        settings.resque
      )

      halt(500) unless github.enact
      halt 202
    end
  end
end

require "sinatra/base"
require "branchinator/services/github"
require "branchinator/services/heroku"

module Branchinator
  class WebApp < Sinatra::Base
    configure do
      set :hoster, Services::Heroku.new
    end

    post "/hooks/github" do
      request.body.rewind
      
      begin
        Services::Github.new(
          env['HTTP_X_GITHUB_EVENT'],
          request.body.read,
          settings.hoster
        ).enact

        halt 200
      rescue
        raise
      end
    end
  end
end

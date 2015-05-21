require "sinatra/base"
require "resque"
require "branchinator/jobs"
require "branchinator/services/github"
require "branchinator/services/heroku"

module Branchinator
  class WebApp < Sinatra::Base
    configure do
      set :jobs, Resque
    end

    post "/hooks/github" do
      request.body.rewind
      
      Services::Github.new(
        env['HTTP_X_GITHUB_EVENT'],
        request.body.read,
        settings.jobs
      ).enact

      halt 202
    end
  end
end

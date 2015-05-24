require "branchinator/jobs"
require "branchinator/services/github"
require "branchinator/services/heroku"

module Branchinator
  class WebApp < Sinatra::Base
    post "/hooks/github" do
      request.body.rewind
      
      github = Services::Github::WebhookPayload.new(
        env,
        request.body.read,
        settings.resque
      )

      halt(403) unless Repo.find_by(name: github.repo_name)
      halt(500) unless github.enact
      halt 202
    end
  end
end
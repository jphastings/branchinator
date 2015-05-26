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

      repo = Repo.find_by(
        name: github.repo_name,
        service: 'github')

      halt(403) unless repo
      halt(500) unless github.enact(repo.source, repo.hoster)
      halt(202)
    end
  end
end
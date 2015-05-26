module Branchinator
  class WebApp < Sinatra::Base
    get "/repos", auth: :user do
      json_list_of current_user.repos
    end

    post "/repos", auth: :user, body: :json do
      source = current_user.credentials.sources.find_by(id: json_body['sourceId'])
      hoster = current_user.credentials.hosters.find_by(id: json_body['hosterId'])
      
      error = "UnknownHoster" unless hoster
      error = "UnknownSource" unless source

      halt(404, {
        error: error,
        developerMessage: "The source or hoster id given could not be found"
      }.to_json) if error

      repo_details = {
        name: json_body['name'],
        source: source,
        hoster: hoster,
        service: source.service
      }

      halt(304) if current_user.repos.exists?(repo_details)
      repo = current_user.repos.create(repo_details)
      halt(201, repo.to_json)
    end

    get "/hosters", auth: :user do
      json_list_of current_user.credentials.hosters
    end
  end
end
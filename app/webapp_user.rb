module Branchinator
  class WebApp < Sinatra::Base
    get "/repos", auth: :user do
      json_list_of current_user.repos
    end

    post "/repos", auth: :user do

    end

    get "/hosters", auth: :user do
      json_list_of current_user.credentials.hosters
    end
  end
end
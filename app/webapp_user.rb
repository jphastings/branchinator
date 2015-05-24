module Branchinator
  class WebApp < Sinatra::Base
    get "/repos" do
      json_list_of current_user.repos
    end
  end
end
require "sinatra/base"
require "digest/md5"

module Branchinator
  class WebApp < Sinatra::Base
    post "/hooks/github" do
      request.body.rewind
      data = request.body.read
      open("data/#{Digest::SHA256.hexdigest(data)}.bin", "w") do |f|
        f.write data
      end
      ""
    end
  end
end

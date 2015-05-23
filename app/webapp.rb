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
      provider :github, ENV['GITHUB_KEY'], ENV['GITHUB_SECRET'], scope: 'repo,admin:repo_hook'
      provider :heroku, ENV['HEROKU_OAUTH_ID'], ENV['HEROKU_OAUTH_SECRET']
    end

    configure do
      set :resque, Resque
    end

    get '/auth/:service/callback' do
      auth = request.env['omniauth.auth']
      creds = Credential.find_or_initialize_by(service: auth.provider, uid: auth.uid)
      was_new = creds.new_record?
      creds.data = {
        token: auth.credentials.token
        # TODO: Add differentiator so you can have multiple accounts associated with one user
      }

      creds.save!

      if creds.users.empty?
        if false # logged in
          creds.users << logged_in_user
        else
          username = auth.extra.raw_info.login rescue [auth.provider, auth.uid].join("-")
          begin
            creds.users.create!(username: username)
          rescue NotImplementedError # TODO: What exception would this be?
            username << "-#{auth.uid}"
            retry
          end
        end
      end

      halt(was_new ? 201 : 200)
    end
  end
end

require_relative "webapp_hooks"
require_relative "webapp_user"
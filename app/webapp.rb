require "sinatra/base"
require "sinatra/activerecord"
require "json"
require "omniauth"
require "omniauth-github"
require "omniauth-heroku"
require_relative "env"

require_relative "webapp_helpers"

module Branchinator
  class WebApp < Sinatra::Base
    register Sinatra::ActiveRecordExtension
    helpers WebAppHelpers

    use Rack::Session::Cookie, key: 'branchinator',
                             # domain: 'foo.com',
                               path: '/',
                               expire_after: 2592000,
                             # old_secret: 'not yet needed',
                               secret: ENV['COOKIE_SECRET']

    use OmniAuth::Builder do
      provider :github, ENV['GITHUB_KEY'], ENV['GITHUB_SECRET'], scope: 'repo,admin:repo_hook'
      provider :heroku, ENV['HEROKU_OAUTH_ID'], ENV['HEROKU_OAUTH_SECRET']
    end

    configure do
      set :resque, Resque
      set(:auth) { |level| condition { authd_only! if level == :user } }
      set(:body) { |format| condition {
        raise NotImplementedError, "Cannot deserialize #{format} bodies" unless format.to_sym == :json
        request.body.rewind
        @json_body = JSON.parse(request.body.read)
      } }
    end

    before do
      content_type :json
    end

    # TODO: Logging in with a second service when the access token is no longer trusted

    get '/auth/:service/callback' do
      auth = request.env['omniauth.auth']
      cred = Credential.find_or_initialize_by(service: auth.provider, uid: auth.uid)
      was_new = cred.new_record?

      if was_new
        cred.data = { token: auth.credentials.token } 
        cred.save!
      end

      if cred.owner
        authd_user = cred.owner
      else
        if current_user.nil?
          username = username_from_auth(auth)
          begin
            authd_user = cred.users.create!(username: username)
          rescue ActiveRecord::RecordNotUnique
            username << "-#{auth.uid}"
            retry
          end
        else
          cred.users << current_user
        end
      end

      if current_session.nil?
        session['access_token'] = authd_user.sessions.create!(
          details: {
            user_agent: env['HTTP_USER_AGENT'],
            ip_address: env['REMOTE_ADDR']
          }
        ).token
      else
        current_session.touch
      end

      halt(was_new ? 201 : 200)
    end

    get '/auth/failure' do
      # TODO
    end
  end
end

require_relative "webapp_hooks"
require_relative "webapp_user"

require "sinatra/base"
require "sinatra/activerecord"
require "json"
require "omniauth"
require "omniauth-github"
require "omniauth-heroku"
require_relative "env"

module Branchinator
  class WebApp < Sinatra::Base
    register Sinatra::ActiveRecordExtension

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
    end

    helpers do
      def current_user
        current_session.user
      end

      def current_session
        @current_session ||= catch(:no_session) do
          token = session['access_token']
          token ||= env['HTTP_AUTHORIZATION'].match(/^Bearer (.+)$/)[1] rescue nil
          throw :no_session if token.nil?
          session = Session.find_by(token: token, active: true)
          throw :no_session if session.nil?
          request_reauth! unless session.age < ENV['SESSION_LIFETIME'].to_f
          session || Naught.build { |c| c.mimic Session }.new
        end
      end
      alias :ensure_session_trust! :current_session

      def request_reauth!
        halt(419, {
          error: "IdentityUncertain",
          developerMessage: "The access token provided is no longer trusted enough for this action."
        })
      end

      def username_from_auth(auth)
        auth.info.nickname || [auth.provider, auth.uid].join("-")
      end

      def json_list_of(list)
        {
          count: list.count,
          items: [],
          links: {}
        }.to_json
      end
    end

    before do
      mime_type :json
    end

    before '/auth/:service' do
      ensure_session_trust!
    end

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
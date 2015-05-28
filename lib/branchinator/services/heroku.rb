require 'platform-api'
require 'tempfile'
require 'rugged'

module Branchinator
  module Services
    class Heroku
      # TODO: readable by this user only
      public_key = Tempfile.new('id_rsa.pub')
      public_key.write(ENV['DEPLOY_KEY_PUBLIC'])
      public_key.rewind
      private_key = Tempfile.new('id_rsa')
      private_key.write(Base64.strict_decode64(ENV['DEPLOY_KEY_PRIVATE']))
      private_key.rewind
      
      CREDENTIALS = Rugged::Credentials::SshKey.new(
        username: 'git',
        publickey: public_key.path,
        privatekey: private_key.path,
        passphrase: ENV['DEPLOY_KEY_PASSPHRASE']
      )

      def initialize(token)
        @heroku = PlatformAPI.connect_oauth(token)
        
        begin
          keys = @heroku.key.list.map { |k| k['fingerprint'] }
          if !keys.include?(ENV['DEPLOY_KEY_FINGERPRINT'])
            @heroku.key.create(public_key: ENV['DEPLOY_KEY_PUBLIC'])
          end
        rescue Excon::Errors::Unauthorized
          puts "Could not access Heroku keys"
        end
      end

      def create_app(app_name)
        @heroku.app.create(name: app_name)
      end

      # TODO: Find or create heroku app efficiently
      def find_or_create_app(app_name)
        create_app(app_name)
      rescue
        @heroku.app.info(app_name)
      end

      def delete_app(app_name)
        @heroku.app.delete(app_name)
      rescue Excon::Errors::NotFound
        { 'name' => app_name }
      end

      def deploy_app(app_name:, code:)
        app = find_or_create_app(app_name)
        Dir.mktmpdir do |dir|
          repo = Rugged::Repository.clone_at(
            code['git_url'],
            dir,
            credentials: CREDENTIALS
          )
          # Hack to get the URL looking right - why is this necessary?
          heroku = repo.remotes.create("heroku", app['git_url'])
          repo.remotes.create("patch", code['then']['git_url']) if code['then']
          repo.checkout(code['commit'])
          if false
            # TODO: Merge in code['then']['commit']
          end
          repo.push("heroku", "HEAD:refs/heads/master", credentials: CREDENTIALS)
        end
        # TODO: Capture git push responses
      end
    end
  end
end

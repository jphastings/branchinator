require 'platform-api'
require 'git'

module Branchinator
  module Services
    class Heroku
      def initialize(token)
        @heroku = PlatformAPI.connect_oauth(token)
        
        keys = @heroku.key.list.map { |k| k['fingerprint'] }
        if !keys.include?(ENV['DEPLOY_KEY_FINGERPRINT'])
          @heroku.key.create(public_key: ENV['DEPLOY_KEY_PUBLIC'])
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
          git = Git.clone(code['git_url'], app_name, path: dir)
          git.chdir do
            heroku_remote = git.add_remote("heroku", app['git_url'])
            patch_remote = git.add_remote("patch", code['then']['git_url']) if code['then']
            
            git.checkout(code['commit'])
            if patch_remote
              git.pull("patch", code['then']['commit'])
            end
            git.push(heroku_remote, "HEAD:refs/heads/master")
          end
        end
        # TODO: Capture git errors
        # TODO: Capture git push responses
        true
      end
    end
  end
end

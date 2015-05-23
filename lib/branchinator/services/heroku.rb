require 'platform-api'
require 'git'

module Branchinator
  module Services
    class Heroku
      def initialize
        @heroku = PlatformAPI.connect_oauth(ENV['HEROKU_OAUTH_TOKEN'])
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
      end

      def deploy_app(app_name:, git_url:, commit:)
        app = find_or_create_app(app_name)
        Dir.mktmpdir do |dir|
          git = Git.clone(git_url, app_name, path: dir)
          heroku_remote = git.add_remote("heroku", app['git_url'])
          git.chdir do
            git.checkout(commit)
            p git.push(heroku_remote, "#{commit}:refs/heads/master")
          end
        end
        true
      end
    end
  end
end

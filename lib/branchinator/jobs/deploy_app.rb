module Branchinator
  module Jobs
    class DeployApp
      extend HostingProvider
      @queue = "apps"

      def self.lock(params)
        params['app_name']
      end

      def self.perform(params)
        puts "Starting deploy: #{params['git_url']}##{params['commit']} to #{params['app_name']}"
        hosting_provider.deploy_app(
          app_name: params['app_name'],
          git_url: params['git_url'],
          commit: params['commit']
        )
        puts "App deployed: #{params['git_url']}##{params['commit']} to #{params['app_name']}"
      end
    end
  end
end
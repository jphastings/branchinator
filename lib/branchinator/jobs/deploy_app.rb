module Branchinator
  module Jobs
    class DeployApp
      extend HostingProvider
      @queue = "apps"

      def self.lock(params)
        params['app_name']
      end

      def self.perform(params)
        puts "Starting deploy: <TODO: name> to #{params['app_name']}"
        hosting_provider(params['hoster_id']).deploy_app(
          app_name: params['app_name'],
          code: params['code']
        )
        puts "App deployed: <TODO: name> to #{params['app_name']}"
      end
    end
  end
end
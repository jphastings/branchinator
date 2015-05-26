module Branchinator
  module Jobs
    class DeleteApp
      extend HostingProvider
      @queue = "apps"

      def self.lock(params)
        params['app_name']
      end

      def self.perform(params)
        app = hosting_provider(params['hoster_id']).delete_app(params['app_name'])
        puts "App deleted: #{app['name']}"
      end
    end
  end
end
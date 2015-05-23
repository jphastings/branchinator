module Branchinator
  module Jobs
    class CreateApp
      extend HostingProvider
      @queue = "apps"

      def self.lock(params)
        params['app_name']
      end

      def self.perform(params)
        app = hosting_provider.create_app(params['app_name'])
        puts "App created: #{app['web_url']}"
      end
    end
  end
end
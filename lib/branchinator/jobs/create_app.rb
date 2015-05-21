require "branchinator/jobs/helpers/hosting_provider"
require "resque/plugins/lock"

module Branchinator
  module Jobs
    class CreateApp
      extend Resque::Plugins::Lock
      include HostingProvider
      @queue = "apps"

      def self.lock(details)
        details[:app_name]
      end

      def self.perform(app_name)
        hosting_provider.create_app(details[:app_name])
      end
    end
  end
end
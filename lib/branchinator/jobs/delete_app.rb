require "branchinator/jobs/helpers/hosting_provider"
require "resque/plugins/lock"

module Branchinator
  module Jobs
    class DeleteApp
      extend Resque::Plugins::Lock
      include HostingProvider
      @queue = "apps"

      def self.lock(details)
        details[:app_name]
      end

      def self.perform(details)
        hosting_provider.delete_app(details[:app_name])
      end
    end
  end
end
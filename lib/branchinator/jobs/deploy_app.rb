require "branchinator/jobs/helpers/hosting_provider"
require "resque/plugins/lock"

module Branchinator
  module Jobs
    class DeployApp
      extend Resque::Plugins::Lock
      include HostingProvider
      @queue = "apps"

      def self.lock(details)
        details[:app_name]
      end

      def self.perform(details)
        hosting_provider.deploy_app(
          app_name: details[:app_name],
          git_url: details[:git_url],
          commit: details[:commit]
        )
      end
    end
  end
end
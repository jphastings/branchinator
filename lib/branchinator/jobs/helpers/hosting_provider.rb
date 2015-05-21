require "branchinator/services/heroku"

module Branchinator
  module Jobs
    module HostingProvider
      # When this is included provide the method #hosting_provider which is a configured
      # hosting provider class
      def hosting_provider
        @hosting_provider ||= Services::Heroku.new
      end
    end
  end
end

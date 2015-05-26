require "branchinator/services/heroku"

module Branchinator
  module Jobs
    module HostingProvider
      # When this is included provide the method #hosting_provider which is a configured
      # hosting provider class
      def hosting_provider(credentials_id)
        cred = ::Branchinator::Credential.hosters.find_by(id: credentials_id)
        raise "Credential ##{credentials_id} no longer exists" unless cred

        Services.const_get(cred.service.capitalize).new(cred.data[:token])
      end
    end
  end
end

require "branchinator/jobs"
require "hashie"
require "json"
require "zlib"

module Branchinator
  module Services
    class Github
      def initialize(event, payload, resque)
        @event = event
        payload = JSON.parse(payload) if payload.is_a?(String)
        @payload = Hashie::Mash.new(payload)
        @resque = resque
      end

      def repo_name
        @payload.repository.full_name
      end

      def enact
        enact_method = "enact_#{@event.downcase}"
        raise NotImplementedError, "Coping with the Github #{@event} event is not implemented" unless respond_to?(enact_method, true)
        send(enact_method)
      end

      private

      def enact_create
        raise NotImplementedError, "Only branch creations are implemented" unless @payload.ref_type == "branch"
        app_name = app_name_for(@payload.repository, @payload.ref)
        @resque.enqueue(Jobs::CreateApp, app_name: app_name)
      end

      def enact_push
        raise NotImplementedError, "Cannot determine the branch from the ref" unless ref = @payload.ref.match(%r{^refs/heads/(?<branch>.*)$})
        app_name = app_name_for(@payload.repository, ref['branch'])
        if @payload.deleted
          @resque.enqueue(Jobs::DeleteApp, app_name: app_name)
        else
          @resque.enqueue(Jobs::DeployApp,
            app_name: app_name,
            git_url: @payload.repository.git_url,
            commit: @payload.after
          )
        end
      end

      def app_name_for(repo, branch_name)
        repo_name = repo.name
        repo_name = "br" + repo.id.to_s(16) if repo.name.length > 10
        branch_name = Zlib::crc32(branch_name).to_s(16) if branch_name.length > 10
        [repo_name, branch_name].join('-')
      end
    end
  end
end

require "branchinator/jobs"
require "hashie"
require "json"
require "zlib"

module Branchinator
  module Services
    module Github
      class WebhookPayload
        def initialize(env, payload, resque)
          @event = env['HTTP_X_GITHUB_EVENT']
          payload = JSON.parse(payload) if payload.is_a?(String)
          @payload = Hashie::Mash.new(payload)
          @resque = resque
        end

        def repo_name
          @payload.repository.full_name
        end

        def enact(source, hoster)
          @source_id = source.id
          @hoster_id = hoster.id
          enact_method = "enact_#{@event.downcase}"
          raise NotImplementedError, "Coping with the Github #{@event} event is not implemented" unless respond_to?(enact_method, true)
          send(enact_method)
        end

        private

        def enact_create
          raise NotImplementedError, "Only branch creations are implemented" unless @payload.ref_type == "branch"
          app_name = app_name_for(@payload.repository, @payload.ref)
          @resque.enqueue(Jobs::CreateApp,
            app_name: app_name,
            source_id: @source_id,
            hoster_id: @hoster_id)
        end

        def enact_push
          branch_name = branch_name_from_ref(@payload.ref)
          app_name = app_name_for(@payload.repository, branch_name)
          if @payload.deleted
            @resque.enqueue(Jobs::DeleteApp,
              app_name: app_name,
              source_id: @source_id,
              hoster_id: @hoster_id)
          else
            @resque.enqueue(Jobs::DeployApp,
              app_name: app_name,
              code: {
                git_url: @payload.repository.git_url,
                commit: @payload.after
              },
              source_id: @source_id,
              hoster_id: @hoster_id)
          end
        end

        def enact_pull_request
          app_name = app_name_for(@payload.repository, @payload.pull_request.head.ref)

          case @payload.action
          when "opened", "reopened"
            @resque.enqueue(Jobs::DeployApp,
              app_name: app_name,
              code: {
                git_url: @payload.pull_request.base.repo.git_url,
                commit: @payload.pull_request.base.sha,
                then: {
                  git_url: @payload.pull_request.head.repo.git_url,
                  commit: @payload.pull_request.head.sha
                }
              },
              source_id: @source_id,
              hoster_id: @hoster_id)
            # TODO: add notification channel
          when "closed"
            @resque.enqueue(Jobs::DeleteApp,
              app_name: app_name,
              source_id: @source_id,
              hoster_id: @hoster_id)
            # TODO: Add notification channel
          else
            raise NotImplementedError, "Pull request '#{@payload.action}' action not implemented"
          end
        end

        def branch_name_from_ref(ref)
          match = ref.match(%r{^refs/heads/(?<branch>.*)$})
          raise NotImplementedError, "Cannot determine the branch from the ref" unless match
          match['branch']
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
end
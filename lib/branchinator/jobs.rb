require_relative "jobs/helpers/hosting_provider"
require "resque/plugins/lock"

require_relative "jobs/create_app"
require_relative "jobs/delete_app"
require_relative "jobs/deploy_app"

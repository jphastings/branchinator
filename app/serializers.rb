require "active_model_serializers"

class ActiveRecord::Base
  alias :original_as_json :as_json
  def as_json(options = {})
    Branchinator.const_get("#{self.class.name}Serializer")
      .new(self)
      .as_json(options)
  rescue
    original_as_json(options)
  end
end

module Branchinator
  class CredentialSerializer < ActiveModel::Serializer
    attributes :id, :service, :description
  end

  class RepoSerializer < ActiveModel::Serializer
    attributes :id, :service, :name
  end
end

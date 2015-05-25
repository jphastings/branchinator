require "active_model_serializers"

module Branchinator
  class CredentialSerializer < ActiveModel::Serializer
    attributes :id, :service, :description
  end
end

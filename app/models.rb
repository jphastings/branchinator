require "naught"
require_relative "serializers"

module Branchinator
  module Serializer
    def serializers
      self.map do |record|
        Branchinator.const_get("#{record.class.name}Serializer").new(record)
      end
    end
  end

  class User < ActiveRecord::Base
    has_many :credential_rights
    has_many :credentials, through: :credential_rights
    has_and_belongs_to_many :repos
    has_many :sessions
  end

  NullUser = Naught.build do
    def nil?
      true
    end
  end

  class Repo < ActiveRecord::Base
    has_and_belongs_to_many :credentials
    has_and_belongs_to_many :users
  end

  class CredentialRight < ActiveRecord::Base
    belongs_to :user
    belongs_to :credential
  end

  class Credential < ActiveRecord::Base
    has_many :credential_rights
    has_many :users, through: :credential_rights
    has_and_belongs_to_many :repos
    serialize :data
    scope :hosters, -> { where(service: %w{heroku}) }

    def owner
      credential_rights.where(owner: true).first.user
    rescue
      nil
    end

    def description
      read_attribute(:data)[:description]
    end
  end

  class Session < ActiveRecord::Base
    belongs_to :user
    before_save :generate_token
    serialize :details

    def age
      Time.now.to_f - updated_at.to_f
    end

    private

    def generate_token
      write_attribute(:token, SecureRandom.base64(24)) if new_record?
    end
  end

  NullSession = Naught.build do
    def nil?
      true
    end

    def user
      NullUser.new
    end
  end
end

module Branchinator
  class User < ActiveRecord::Base
    has_many :credential_rights
    has_many :credentials, through: :credential_rights
    has_and_belongs_to_many :repos
    has_many :sessions
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

    def owner
      credential_rights.where(owner: true).first.user
    rescue
      nil
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
end

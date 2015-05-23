module Branchinator
  class User < ActiveRecord::Base
    has_and_belongs_to_many :credentials
    has_and_belongs_to_many :repos
  end

  class Repo < ActiveRecord::Base
    has_and_belongs_to_many :credentials
    has_and_belongs_to_many :users
  end

  class Credential < ActiveRecord::Base
    has_and_belongs_to_many :users
    has_and_belongs_to_many :repos
  end
end

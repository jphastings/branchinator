begin
  require "dotenv"
  Dotenv.load
rescue LoadError
end
require_relative "../app/env"
require 'irb/ext/save-history'
IRB.conf[:SAVE_HISTORY] = 100
IRB.conf[:HISTORY_FILE] = ".irb-history"

begin
  require "dotenv"
  Dotenv.load
rescue LoadError
end
require "env"
require "branchinator/jobs"

include Branchinator

puts "Branchinator Console… GO!"
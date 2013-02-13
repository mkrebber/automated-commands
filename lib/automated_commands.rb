require "automated_commands/version"
require "automated_commands/test_result"

require "rails/commands/tester"
require "automated_commands/rails/console_methods"

require "automated_commands/railtie" if defined?(Rails)

if defined?(Rake)
  Dir[File.join(File.dirname(__FILE__), "../tasks/*.rake")].each { |ext| load ext }
end
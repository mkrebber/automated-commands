module AutomatedCommands
  class TestResult < Struct.new(:errors, :failures, :skips, :test_count, :assertion_count)
  end
end
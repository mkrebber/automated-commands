# encoding: utf-8
require 'drb'

module AutomatedCommands
  module Rails
    module ConsoleMethods
      def start_test_listener
        original_trap = Signal.trap("SIGINT", proc { raise "exit" })

        mapping = {
          "models" => "unit",
          "controllers" => "functional"
        }

        distributed_test_result = TestResult.new(0, 0, 0, 0, 0)
        last_test_result = nil

        DRb.start_service 'druby://:9191', distributed_test_result

        loop do
          begin
            input = open(::Rails.root.join("test_pipe"), "r+")

            path = input.gets # e.g. test/unit/some_test.rb

            reload!
            if path =~ /test\/(.*)\/(.*)_test\.rb/
              test "#{$1}/#{$2}"

              if last_test_result.present? && last_test_result.failures > 0 && distributed_test_result.failures < 1
                test $1
              end
              last_test_result = distributed_test_result.dup

            elsif path =~ /app\/(.*)\/(.*)\.rb/
              tests = "#{mapping[$1]}/#{$2}"

              test tests
            end
          rescue => e
            p e
            break
          end
        end

        Signal.trap("SIGINT", &original_trap)
        DRb.stop_service

        nil
      end
    end
  end
end

# monkey patch commands to publish test results via drb
module Rails
  module Commands
    class Tester
      private
      def trigger_runner
        if defined?(Test::Unit::TestCase) && ActiveSupport::TestCase.ancestors.include?(Test::Unit::TestCase)
          runner = MiniTest::Unit.runner
          runner.run

          counter = DRbObject.new nil, 'druby://:9191'
          counter.errors = runner.errors
          counter.failures = runner.failures
          counter.skips = runner.skips
          counter.test_count = runner.test_count
          counter.assertion_count = runner.assertion_count
        else
          # MiniTest::Spec setups in Rails 4.0+ has autorun defined
        end
      end
    end
  end
end
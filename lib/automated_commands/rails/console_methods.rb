# encoding: utf-8
require 'drb'
require 'listen'
require 'pathname'

module AutomatedCommands
  module Rails
    module ConsoleMethods
      def start_test_listener
        %x[mkfifo ./test_pipe]

        change_listener = setup_change_listener
        change_listener.start false

        original_trap = Signal.trap("SIGINT", proc { raise "exit" })
        handle_file_changes # blocks until user stops using STRG+C
        Signal.trap("SIGINT", &original_trap)

        change_listener.stop
        %x[rm ./test_pipe]

        nil
      end

      private

      def handle_file_changes
        distributed_test_result = TestResult.new(0, 0, 0, 0, 0)
        last_test_result = nil

        mapping = {
          "models" => "unit",
          "controllers" => "functional"
        }

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

        DRb.stop_service
        nil
      end

      def setup_change_listener
        return ::Listen::MultiListener.new('test', 'app', filter: /.*\.rb$/, latency: 0.2) do |modified, added, removed|
          output = open("test_pipe", "w+")

          (modified || []).each do |modified_file|
            path = Pathname.new(modified_file)

            output.puts path.relative_path_from(Pathname.pwd)
            output.flush
          end

          (added || []).each do |added_file|
            path = Pathname.new(added_file)

            output.puts path.relative_path_from(Pathname.pwd)
            output.flush
          end
        end
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
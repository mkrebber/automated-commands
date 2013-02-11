# encoding: utf-8
module AutomatedCommands
  module Rails
    module ConsoleMethods
      def start_test_listener
        original_trap = Signal.trap("SIGINT", proc { raise "exit" })

        loop do
          begin
            input = open(::Rails.root.join("test_pipe"), "r+")

            path = input.gets # e.g. test/unit/some_test.rb

            if path =~ /test\/(.*)\/.*\.rb/
              p "test '#{$1}'"
              test $1
            end
          rescue => e
            break
          end
        end

        Signal.trap("SIGINT", &original_trap)
        nil
      end
    end
  end
end
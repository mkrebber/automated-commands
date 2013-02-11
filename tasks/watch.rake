namespace :automated_commands do
  desc "watch TestUnit files for changes"
  task :watch do
    require 'listen'
    require 'pathname'

    %x[mkfifo ./test_pipe]
    at_exit {
      %x[rm ./test_pipe]
    }

    Listen.to('test', :filter => /.*_test\.rb$/, :latency => 0.2) do |modified, added, removed|
      output = open("test_pipe", "w+")
      path = Pathname.new(modified.first)

      output.puts path.relative_path_from(Pathname.pwd)
      output.flush
    end
  end
end
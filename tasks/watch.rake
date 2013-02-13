namespace :automated_commands do
  desc "watch TestUnit files for changes"
  task :watch do
    require 'listen'
    require 'pathname'

    %x[mkfifo ./test_pipe]
    at_exit { %x[rm ./test_pipe] }

    p "listening for changes in your tests"

    Listen.to('test', 'app', filter: /.*\.rb$/, latency: 0.2) do |modified, added, removed|
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
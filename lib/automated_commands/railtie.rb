# encoding: UTF-8
module AutomatedCommands
  class Railtie < ::Rails::Railtie
    initializer "automated_commands.environment" do |app|
      if ::Rails.env.test? && defined?(::IRB)
        ::IRB::ExtendCommandBundle.send :include, ::AutomatedCommands::Rails::ConsoleMethods
      end
    end
  end
end

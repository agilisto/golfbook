namespace :hoptoad do
  desc "Notify Hoptoad of a new deploy."
  task :deploy => :environment do
    require 'hoptoad_tasks'
    HoptoadTasks.deploy_to(ENV['TO'])
  end

  desc "Verify your plugin installation by sending a test exception to the hoptoad service"
  task :test => :environment do
    require 'action_controller/test_process'

    request = ActionController::TestRequest.new

    response = ActionController::TestResponse.new

    class HoptoadTestingException < RuntimeError; end

    unless HoptoadNotifier.api_key
      puts "Hoptoad needs an API key configured! Check the README to see how to add it."
      exit
    end

#this did not work - had to add it manually to the application controller.
#    in_controller = ApplicationController.included_modules.include? HoptoadNotifier::Catcher
    in_base = ActionController::Base.included_modules.include? HoptoadNotifier::Catcher
    if !in_base #!in_controller ||
      puts "HoptoadNotifier::Catcher must be included inside your ApplicationController class."
      exit
    end

    puts 'Setting up the Controller.'
#    class ApplicationController #this did not work
    class ApplicationController < ActionController::Base
      # This is to bypass any filters that may prevent access to the action.
      prepend_before_filter :test_hoptoad
      def test_hoptoad
        puts "Raising '#{exception_class.name}' to simulate application failure."
        raise exception_class.new, 'Testing hoptoad via "rake hoptoad:test". If you can see this, it works.'
      end

      def rescue_action exception
        rescue_action_in_public exception
      end

      def public_environment?
        true
      end

      # Ensure we actually have an action to go to.
      def verify; end

      def exception_class
        exception_name = ENV['EXCEPTION'] || "HoptoadTestingException"
        Object.const_get(exception_name)
      rescue
        Object.const_set(exception_name, Class.new(Exception))
      end
    end

    puts 'Processing request.'
    class HoptoadVerificationController < ApplicationController; end
    HoptoadVerificationController.new.process(request, response)
  end
end


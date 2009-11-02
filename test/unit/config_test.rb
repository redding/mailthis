require File.dirname(__FILE__) + '/../test_helper'

class Mailer::ConfigTest < Test::Unit::TestCase

  context "The Mailer::Config" do

    should_have_accessors *[:server, :domain, :port, :username, :password, :authentication, :environment, :default_from]
    should_have_readers :logger
    should_have_writers :log_file
    should_have_instance_methods "check"
    
    KNOWN_ENVIRONMENTS.each do |environment|
      context "in #{environment}" do
        setup do
          @config = Mailer::Config.new
          @config.environment = environment
        end
        subject { @config }
        should_have_instance_methods "#{environment}?"
        should "know its environment" do
          assert subject.send("#{environment}?")
          KNOWN_ENVIRONMENTS.reject{|e| e == environment}.each do |other_environment|
            assert !subject.send("#{other_environment}?")
          end
        end
      end
    end
    
    # TODO: build in deliveries framework and test
        
  end

end
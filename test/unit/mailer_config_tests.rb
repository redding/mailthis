require File.dirname(__FILE__) + '/../test_helper'

class Mailer::ConfigTest < Test::Unit::TestCase

  context "The Mailer::Config" do

    should_have_accessors *[:smtp_helo_domain, :smtp_server, :smtp_port, :smtp_username, :smtp_password, :smtp_auth_type, :environment, :default_from]
    should_have_readers :logger
    should_have_writers :log_file
    
    should_have_instance_methods "check"
    # TODO: write config check tests
    context "configured" do
      setup do
        Mailer.configure do |config|
          config.smtp_helo_domain = "example.com"
          config.smtp_server = "smtp.example.com"
          config.smtp_port = 25
          config.smtp_username = "test@example.com"
          config.smtp_password = "secret"
          config.smtp_auth_type = :plain
          config.environment = Mailer.test
        end
      end
      context "without a helo domain" do
        setup do
          Mailer.config.smtp_helo_domain = nil
        end
        should_not_pass_the_config_check
      end
      context "without a server" do
        setup do
          Mailer.config.smtp_server = nil
        end
        should_not_pass_the_config_check
      end
      context "without a port" do
        setup do
          Mailer.config.smtp_port = nil
        end
        should_not_pass_the_config_check
      end
      context "without a username" do
        setup do
          Mailer.config.smtp_username = nil
        end
        should_not_pass_the_config_check
      end
      context "without a password" do
        setup do
          Mailer.config.smtp_password = nil
        end
        should_not_pass_the_config_check
      end
      context "without an auth_type" do
        setup do
          Mailer.config.smtp_auth_type = nil
        end
        should_not_pass_the_config_check
      end
      context "without an environment" do
        setup do
          Mailer.config.environment = nil
        end
        should_not_pass_the_config_check
      end
    end
      
            
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
    
  end

end
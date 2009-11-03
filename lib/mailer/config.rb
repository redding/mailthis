require 'mailer/exceptions'

module Mailer
  class Config

    # TODO: look into abstracting port settings better based on server access type
    # => ie, TLS or SSL or whatever
    CONFIGS = [:smtp_helo_domain, :smtp_server, :smtp_port, :smtp_username, :smtp_password, :smtp_auth_type, :environment, :default_from]
    NOT_REQUIRED = [:default_from]
    CONFIGS.each do |config|
      attr_accessor config
    end
    attr_reader :logger
    
    def initialize()
      @logger = Log4r::Logger.new("[mailer]")
      @logger.add(Log4r::StdoutOutputter.new('console'))

      @smtp_auth_type ||= :login
      @environment ||= Mailer::ENVIRONMENT[:development]
    end
    
    def smtp_username=(value)
      if @default_from.nil? && value && !value.match(/\A([\w\.\-\+]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})\z/i).nil?
        @default_from = value
      end
      @smtp_username = value
    end
    
    def log_file=(file)
      @logger.add(Log4r::FileOutputter.new('fileOutputter', :filename => file, :trunc => false, :formatter => Log4r::PatternFormatter.new(:pattern => "[%l] %d :: %m"))) #rescue nil
    end
    
    def check
      CONFIGS.reject{|c| NOT_REQUIRED.include?(c)}.each do |config|
        raise Mailer::ConfigError, "#{config} not configured." unless instance_variable_get("@#{config}")
      end
    end
    
    def development?
      environment.to_s == Mailer::ENVIRONMENT[:development]
    end
    def test?
      environment.to_s == Mailer::ENVIRONMENT[:test]
    end
    def production?
      environment.to_s == Mailer::ENVIRONMENT[:production]
    end
    
  end
end

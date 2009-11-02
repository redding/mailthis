require 'mailer/exceptions'

module Mailer
  class Config

    # TODO: look into abstracting port settings better based on server access type
    # => ie, TLS or SSL or whatever
    CONFIGS = [:server, :domain, :port, :username, :password, :authentication, :environment, :default_from]
    CONFIGS.each do |config|
      attr_accessor config
    end
    attr_reader :logger
    
    def initialize(configs={})
      @logger = Log4r::Logger.new("[mailer]")
      @logger.add(Log4r::StdoutOutputter.new('console'))

      CONFIGS.each do |config|
        instance_variable_set("@#{config}", configs[config])
      end
      @authentication ||= :login
      @environment ||= Mailer::ENVIRONMENT[:development]
      @default_from ||= @username
    end
    
    def log_file=(file)
      @logger.add(Log4r::FileOutputter.new('fileOutputter', :filename => file, :trunc => false, :formatter => Log4r::PatternFormatter.new(:pattern => "[%l] %d :: %m"))) rescue nil
    end
    
    def check
      CONFIGS.each do |config|
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

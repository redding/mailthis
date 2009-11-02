require 'mailer/exceptions'

module Mailer
  class Config
    include Mailer::Exceptions
    
    CONFIGS = [:server, :domain, :port, :reply_to, :username, :password, :authentication, :content_type, :charset, :environment]
    CONFIGS.each do |config|
      attr_reader config
    end
    attr_reader :logger
    
    def initialize(configs={})
      @logger = Log4r::Logger.new("[mailer]")
      @logger.add(Log4r::StdoutOutputter.new('console'))

      CONFIGS.each do |config|
        instance_variable_set("@#{config}", configs[config])
      end
      @authentication ||= :login
      @reply_to ||= @username
      @content_type ||= 'text/plain'
      @charset ||= 'UTF-8'
      @environment ||= 'development'
    end
    
    def log_file=(file)
      @logger.add(Log4r::FileOutputter.new('fileOutputter', :filename => file, :trunc => false, :formatter => Log4r::PatternFormatter.new(:pattern => "[%l] %d :: %m"))) rescue nil
    end
    
    def check
      CONFIGS.each do |config|
        raise Mailer::ConfigError, "#{config} not configured." unless instance_variable_get("@#{config}")
      end
    end
    
  end
end

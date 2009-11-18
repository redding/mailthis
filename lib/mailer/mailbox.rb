require 'mailer/exceptions'
require 'mailer/pop_ssl'

module Mailer
  
  class Mailbox

    CONFIGS = [:server, :port, :email, :password]
    CONFIGS.each do |config|
      attr_reader config
    end
    attr_reader :logger, :log_file

    def initialize(configs={})
      @logger = Log4r::Logger.new("[mailer]")
      @logger.add(Log4r::StdoutOutputter.new('console'))

      configs.each do |config, value|
        instance_variable_set("@#{config.to_s}", value)
      end
      
      if @log_file
        begin
          @logger.add(Log4r::FileOutputter.new('fileOutputter', {
            :filename => @log_file,
            :trunc => false,
            :formatter => Log4r::PatternFormatter.new(:pattern => "[%l] %d :: %m")
          }))
        rescue Exception => err
        end
      end
      
      Net::POP3.enable_ssl(OpenSSL::SSL::VERIFY_NONE)
      
      configs
    end
    
    # opens the mailbox returning the pop3 mailbox object
    def open
      start_pop do |box|
        yield box
      end
    end
    
    # opens the mail box and returns the mails as a collection
    def check
      start_pop do |box|
        if block_given?
          yield box.mails
        end
      end
    end
    
    def empty?
      start_pop do |box|
        box.mails.empty?
      end
    end
    
    def empty!
      start_pop do |box|
        box.mails.each {|mail| mail.delete!}
      end
    end
    
    private
    
    def start_pop(&block)
      Net::POP3.start(@server, @port, @email, @password, &block)
    end

  end
  
end

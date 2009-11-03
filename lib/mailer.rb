require 'openssl'
require 'net/smtp'
require 'tmail'
require 'log4r'

require 'mailer/exceptions'
require 'mailer/config'
require 'mailer/deliveries'
require 'mailer/tls'

module Mailer
  
  REQUIRED_FIELDS = [:from, :to, :subject]
  DEFAULT_CONTENT_TYPE = "text/plain"
  DEFAULT_CHARSET = "UTF-8"
  
  ENVIRONMENT = {
    :development => 'development',
    :test => 'test',
    :production => 'production'
  }
  def self.development
    ENVIRONMENT[:development]
  end
  def self.test
    ENVIRONMENT[:test]
  end
  def self.production
    ENVIRONMENT[:production]
  end
  
  @@config ||= Mailer::Config.new
  def self.configure
    yield @@config
  end
  def self.config
    @@config
  end
  
  @@deliveries ||= Mailer::Deliveries.new
  def self.deliveries
    @@deliveries
  end
  
  # Macro style helper for sending email based on the Mailer configuration
  def self.send(settings={})
    mail = build_tmail(settings)
    mail.body = yield(mail) if block_given?
    mail.body ||= ''
    deliver_tmail(mail)
    # TODO: support :cc and :bcc as well
    log(:info, "Sent '#{mail.subject}' to #{mail.to.join(',')}")
    mail
  end

  # Returns a tmail Mail obj based on a hash of settings
  # => same settings that the .send macro accepts
  def self.build_tmail(some_settings)
    settings = some_settings.dup
    settings[:from] ||= @@config.default_from
    mail = TMail::Mail.new

    # Defaulted settings
    mail.date = Time.now
    mail.content_type = DEFAULT_CONTENT_TYPE
    mail.charset = DEFAULT_CHARSET

    # Required settings
    REQUIRED_FIELDS.each {|field| mail.send("#{field}=", settings.delete(field))}

    # Optional settings
    # => settings "pass thru" to the tmail Mail obj
    settings.each do |field, value|
      mail.send("#{field}=", value) if mail.respond_to?("#{field}=")
    end

    mail
  end
  
  # Deliver a tmail Mail obj depending on configured environment
  # => production?: using Net::SMTP
  # => test?: add to deliveries cache
  # => development?: log mail
  def self.deliver_tmail(mail)
    check_mail(mail)
    @@config.check
    if @@config.production?
      # deliver using Net::SMTP
      Net::SMTP.start(@@config.smtp_server, @@config.smtp_port, @@config.smtp_helo_domain, @@config.smtp_username, @@config.smtp_password, @@config.smtp_auth_type) do |server|
        # TODO: support :cc and :bcc as well
        mail.to.each {|recipient| server.send_message(mail.to_s, mail.from, recipient) }
      end
    elsif @@config.test?
      # Add to the deliveries cache
      @@deliveries << mail
    else
      # Log a delivery
      log_tmail(mail)
    end
  end
  
  # Logs a tmail Mail obj delivery
  def self.log_tmail(mail)
    log(:debug, mail.to_s)
  end
  
  protected
  
  def self.check_mail(tmail)
    raise Mailer::SendError, "cannot send, bad mail object given." unless tmail && tmail.kind_of?(TMail::Mail)
    REQUIRED_FIELDS.each do |field|
      raise Mailer::SendError, "cannot send, #{field} not specified." unless tmail.send(field)
    end
  end
  
  def self.log(level, msg)
    if(msg)
      if MAILER_LOG_AS_PUTS
        puts "[#{level.to_s.upcase}]: [mailer] #{msg}" if Mailer.config.development?
      elsif @@config.logger && @@config.logger.respond_to?(level)
        @@config.logger.send(level.to_s, msg) 
      end
    end
  end

end

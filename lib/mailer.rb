require 'openssl'
require 'net/smtp'
require 'tmail'

require 'mailer/exceptions'
require 'mailer/config'
require 'mailer/tls'

module Mailer
  
  ENVIRONMENT = {
    :development => 'development',
    :production => 'production'
  }
  def self.development
    ENVIRONMENT[:development]
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
  
  def self.send(settings={})
    @@config.check
    mail = generate_mail(settings)
    mail.body = yield(mail) if block_given?
    mail.body ||= ''
    @@config.environment.to_s == Mailer::ENVIRONMENT[:production] ? send_mail(mail) : log_mail(mail)
    log(:info, "Sent '#{mail.subject}' to #{mail.to.join(',')}")
    mail
  end

  protected
  
  def self.generate_mail(settings)
    check_settings(settings)
    mail = TMail::Mail.new

    # Required settings
    mail.from = Array.new([settings[:from]])
    mail.to = Array.new([settings[:to]])
    mail.subject = settings[:subject]

    # Optional settings
    # => TODO, write better handler to let tmail settings just "pass thru"
    mail.date = settings.has_key?(:date) ? settings[:date] : Time.now
    mail.set_content_type(settings.has_key?(:content_type) ? settings[:content_type] : 'text/plain')
    mail.charset = settings.has_key?(:charset) ? settings[:charset] : 'UTF-8'
    mail.reply_to = Array.new([settings[:reply_to]]) if settings.has_key?(:reply_to)
    mail.cc = Array.new([settings[:cc]]) if settings.has_key?(:cc)
    mail.bcc = Array.new([settings[:bcc]])  if settings.has_key?(:bcc)

    mail
  end
  
  def self.send_mail(mail)
    raise Mailer::SendError, "cannot send, bad (or empty) mail object given." unless mail
    Net::SMTP.start(@@config.server, @@config.port, @@config.domain, @@config.username, @@config.password, @@config.authentication) do |server|
      mail.to.each {|recipient| server.send_message(mail.to_s, mail.from, recipient) }
    end
  end
  
  def self.log_mail(mail)
    log(:debug, mail.to_s)
  end
  
  def self.check_settings(settings)
    settings[:from] ||= @@config.default_from
    [:from, :to, :subject].each do |setting|
      raise Mailer::SendError, "cannot send, #{setting} not specified." unless settings[setting]
    end
  end
  
  def self.log(level, msg)
    if(msg)
      if @@config.logger && @@config.logger.respond_to?(level)
        @@config.logger.send(level.to_s, msg) 
      else
        puts "[#{level.to_s.upcase}]: [mailer] #{msg}"
      end
    end
  end

end

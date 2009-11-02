require 'openssl'
require 'net/smtp'
require 'tmail'

require 'mailer/exceptions'
require 'mailer/config'
require 'mailer/tls'

module Mailer
  
  @@config ||= Mailer::Config.new
  def self.configure
    yield @@config
  end
  def self.config
    @@config
  end
  
  def self.send(settings={})
    @@config.check
    [:to, :subject].each do |setting|
      raise Mailer::SendError, "cannot send, #{setting} not specified." unless settings[setting]
    end
    mail = generate_mail(settings)
    mail.body = yield(mail) if block_given?
    mail.body ||= ''
    @@config.environment.to_s == 'production' ? send_mail(mail) : log_mail(mail)
    log(:info, "Sent '#{mail.subject}' to #{mail.to.join(',')}")
    mail
  end

  protected
  
  def self.generate_mail(settings)
    mail = TMail::Mail.new
    mail.to = Array.new([settings[:to]])
    mail.from = @@config.reply_to
    mail.reply_to = @@config.reply_to
    mail.subject = settings[:subject]
    mail.date = Time.now
    mail.set_content_type @@config.content_type
    mail.charset = @@config.charset
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

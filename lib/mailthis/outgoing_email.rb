require 'mail'
require 'mailthis/exceptions'
require 'mailthis/net_smtp_tls'

module Mailthis

  class OutgoingEmail

    # deliver a message using using Net::SMTP with TLS encryption
    # it is recommended to use Mail (https://github.com/mikel/mail) messages
    # to disable delivery, set `ENV['MAILTHIS_DISABLE_SEND'] = 'yes'`

    REQUIRED_FIELDS = [:from, :subject]
    ADDRESS_FIELDS  = [:to, :cc, :bcc]

    attr_reader :mailer, :message

    def initialize(mailer, message)
      @mailer, @message = mailer, message
      @message.from     ||= @mailer.from  if @message.respond_to?(:from=)
      @message.reply_to ||= @message.from if @message.respond_to?(:reply_to=)
    end

    def validate!
      if !valid_message?
        raise Mailthis::MessageError, "invalid message"
      end

      REQUIRED_FIELDS.each do |field|
        if @message.send(field).nil?
          raise Mailthis::MessageError, "missing `#{field}` field"
        end
      end

      if !address_exists?
        raise Mailthis::MessageError, "no #{ADDRESS_FIELDS.join('/')} specified"
      end
    end

    def deliver
      self.validate!
      @mailer.validate!
      deliver_smtp if ENV['MAILTHIS_DISABLE_SEND'].nil?

      log_message # and return it
    end

    private

    def valid_message?
      (REQUIRED_FIELDS + ADDRESS_FIELDS + [:to_s]).inject(true) do |invalid, meth|
        invalid && @message.respond_to?(meth)
      end
    end

    def address_exists?
      ADDRESS_FIELDS.inject(false) do |exists, field|
        exists || (!@message.send(field).nil? && !@message.send(field).empty?)
      end
    end

    def deliver_smtp
      smtp_start_args = [
        @mailer.smtp_server,
        @mailer.smtp_port,
        @mailer.smtp_helo,
        @mailer.smtp_user,
        @mailer.smtp_pw,
        @mailer.smtp_auth
      ]

      Net::SMTP.start(*smtp_start_args) do |smtp|
        ADDRESS_FIELDS.each do |field|
          if (recipients = @message.send(field))
            recipients.each{ |r| smtp.send_message(@message.to_s, @message.from, r) }
          end
        end
      end
    end

    def log_message
      @message.tap do |msg|
        log "Sent '#{msg.subject}' to #{msg.to ? msg.to.join(', ') : "''"}"

        log "\n"\
            "==============================================================\n"\
            "#{msg}\n"\
            "==============================================================\n", :debug
      end
    end

    def log(msg, level = nil)
      @mailer.logger.send(level || :info, msg)
    end

  end

end

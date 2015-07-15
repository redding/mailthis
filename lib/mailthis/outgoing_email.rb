require 'mailthis/exceptions'
require 'mailthis/message'
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
      raise Mailthis::MessageError, "invalid message" if !valid_message?(message)

      @mailer, @message = mailer, message
      @message.from     ||= @mailer.from
      @message.reply_to ||= @message.from
    end

    def validate!
      REQUIRED_FIELDS.each do |field|
        if !field_present?(@message, field)
          raise Mailthis::MessageError, "missing `#{field}` field"
        end
      end

      if !fields_present?(@message, ADDRESS_FIELDS)
        raise Mailthis::MessageError, "no #{ADDRESS_FIELDS.join('/')} specified"
      end
    end

    def deliver
      self.validate!
      @mailer.validate!
      deliver_smtp if ENV['MAILTHIS_DISABLE_SEND'].nil?

      log_message(@message)
      @message
    end

    private

    def valid_message?(message)
      message.kind_of?(Mailthis::Message)
    end

    def fields_present?(message, fields)
      fields.inject(false){ |present, f| present || field_present?(message, f) }
    end

    def field_present?(message, field)
      !message.send(field).nil? && !message.send(field).empty?
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

    def log_message(msg)
      log "Sent '#{msg.subject}' to #{msg.to ? msg.to.join(', ') : "''"}"
      log debug_log_entry(msg), :debug
    end

    def debug_log_entry(msg)
      "\n"\
      "==============================================================\n"\
      "#{msg}\n"\
      "==============================================================\n"
    end

    def log(msg, level = nil)
      @mailer.logger.send(level || :info, msg)
    end

  end

end

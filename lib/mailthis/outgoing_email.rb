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

    def deliver_dry_run
      self.validate!
      @mailer.validate!

      yield(self.message) if block_given?

      log_message(self.message)
      self.message
    end

    def deliver
      self.deliver_dry_run do |msg|
        deliver_smtp(msg) if ENV['MAILTHIS_DISABLE_SEND'].nil?
      end
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

    def deliver_smtp(msg)
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
          if (recipients = msg.send(field))
            recipients.each{ |r| smtp.send_message(msg.to_s, msg.from, r) }
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

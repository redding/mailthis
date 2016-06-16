require 'much-plugin'
require 'mailthis/exceptions'
require 'mailthis/message'
require 'mailthis/outgoing_email'

module Mailthis

  module Mailer
    include MuchPlugin

    plugin_included do
      include InstanceMethods

    end

    REQUIRED_SETTINGS = [
      :smtp_helo,
      :smtp_server,
      :smtp_port,
      :smtp_user,
      :smtp_pw,
      :smtp_auth,
      :from,
      :logger
    ].freeze
    DEFAULT_AUTH = 'login'.freeze

    def self.new(*args, &block)
      if !ENV['MAILTHIS_TEST_MODE']
        MailthisMailer.new(*args, &block)
      else
        TestMailer.new(*args, &block)
      end
    end

    module InstanceMethods

      def initialize(&block)
        @nil_settings = nil
        @smtp_auth    = DEFAULT_AUTH
        @logger       = NullLogger.new

        self.instance_eval(&block) if block
      end

      def smtp_helo(value = nil)
        @smtp_helo = value if !value.nil?
        @smtp_helo
      end

      def smtp_server(value = nil)
        @smtp_server = value if !value.nil?
        @smtp_server
      end

      def smtp_port(value = nil)
        @smtp_port = value if !value.nil?
        @smtp_port
      end

      def smtp_user(value = nil)
        @smtp_user = value if !value.nil?
        @smtp_user
      end

      def smtp_pw(value = nil)
        @smtp_pw = value if !value.nil?
        @smtp_pw
      end

      def smtp_auth(value = nil)
        @smtp_auth = value.to_s if !value.nil?
        @smtp_auth
      end

      def from(value = nil)
        @from = value if !value.nil?
        @from
      end

      def logger(value = nil)
        @logger = value if !value.nil?
        @logger
      end

      def valid?
        !@nil_settings.nil? && @nil_settings.empty?
      end

      def validate!
        @from = self.smtp_user if @from.nil?

        @nil_settings = []
        REQUIRED_SETTINGS.each{ |s| @nil_settings << s if self.send(s).nil? }
        if !self.valid?
          raise(MailerError, "missing required settings: #{@nil_settings.join(', ')}")
        end

        self # for chaining
      end

      def deliver(message = nil, &block)
        (message || ::Mailthis::Message.new).tap do |msg|
          msg.instance_eval(&block) if block
          OutgoingEmail.new(self, msg).deliver
        end
      end

    end

    class NullLogger
      require 'logger'
      ::Logger::Severity.constants.each do |name|
        define_method(name.downcase){ |*args| } # no-op
      end
    end

  end

  class MailthisMailer
    include Mailer

  end

  class TestMailer
    include Mailer

    attr_reader :delivered_messages

    def initialize(*args, &block)
      super
      @delivered_messages = []
    end

    def deliver(*args, &block)
      super(*args, &block).tap do |msg|
        @delivered_messages << msg
      end
    end

    def reset
      self.delivered_messages.clear
    end

  end

end

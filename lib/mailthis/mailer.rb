require 'ns-options/proxy'
require 'mailthis/exceptions'
require 'mailthis/message'
require 'mailthis/outgoing_email'

module Mailthis

  module Mailer

    def self.new(*args, &block)
      if !ENV['MAILTHIS_TEST_MODE']
        MailthisMailer.new(*args, &block)
      else
        TestMailer.new(*args, &block)
      end
    end

    def self.included(klass)
      klass.class_eval do
        include NsOptions::Proxy
        include InstanceMethods

        option :smtp_helo,   String,  :required => true
        option :smtp_server, String,  :required => true
        option :smtp_port,   Integer, :required => true
        option :smtp_user,   String,  :required => true
        option :smtp_pw,     String,  :required => true
        option :smtp_auth,   String,  :required => true, :default => proc{ "login" }

        option :from,   String, :required => true
        option :logger,         :required => true, :default => proc{ NullLogger.new }

      end
    end

    module InstanceMethods

      def initialize(values = nil, &block)
        # this is defaulted here because we want to use the Configuration instance
        # `smtp_user`. If we define a proc above, we will be using the Configuration
        # class `smtp_user`, which will not update the option as expected.
        super((values || {}).merge(:from => proc{ self.smtp_user }))
        self.define(&block)
      end

      def validate!
        raise(MailerError, "missing required settings") if !valid?
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

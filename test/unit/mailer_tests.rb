require 'assert'
require 'mailthis/mailer'

require 'mailthis/exceptions'
require 'mailthis/message'

module Mailthis::Mailer

  class UnitTests < Assert::Context
    desc "Mailthis::Mailer"
    setup do
      @current_test_mode = ENV['MAILTHIS_TEST_MODE']
      ENV['MAILTHIS_TEST_MODE'] = 'yes'
    end
    teardown do
      ENV['MAILTHIS_TEST_MODE'] = @current_test_mode
    end
    subject{ Mailthis::Mailer }

    should have_imeths :new

    should "return a mailthis mailer using `new`" do
      ENV.delete('MAILTHIS_TEST_MODE')
      mailer = subject.new
      assert_instance_of Mailthis::MailthisMailer, mailer
    end

    should "return a test mailer using `new` in test mode" do
      mailer = subject.new
      assert_instance_of Mailthis::TestMailer, mailer
    end

  end

  class InitTests < UnitTests
    desc "when init"
    setup do
      @mailer_class = Class.new do
        include Mailthis::Mailer
      end
      @mailer = @mailer_class.new
    end
    subject{ @mailer }

    should have_imeths :smtp_helo, :smtp_server, :smtp_port
    should have_imeths :smtp_user, :smtp_pw, :smtp_auth
    should have_imeths :from, :logger
    should have_imeths :validate!, :deliver

    should "know its smtp settings" do
      { :smtp_helo   => Factory.string,
        :smtp_server => Factory.string,
        :smtp_port   => Factory.integer,
        :smtp_user   => Factory.email,
        :smtp_pw     => Factory.string
      }.each do |setting, val|
        assert_nil subject.send(setting)

        subject.send(setting, val)
        assert_equal val, subject.send(setting)
      end
    end

    should "use `\"login\"` as the auth by default" do
      assert_equal "login", subject.smtp_auth

      subject.smtp_auth 'plain'
      assert_equal 'plain', subject.smtp_auth
    end

    should "use the smtp user as the from by default" do
      assert_nil subject.from

      subject.smtp_user 'user'
      assert_equal 'user', subject.from
    end

    should "allow overriding the from" do
      subject.from 'a-user'
      assert_equal 'a-user', subject.from
    end

    should "use a null logger by default" do
      assert_kind_of Mailthis::Mailer::NullLogger, subject.logger
    end

  end

  class SendMailTests < InitTests
    desc "and sending mail"
    setup do
      @message = Factory.message(:from => "me@example.com")
      @mailer  = Factory.mailer
      @mailer.logger = Factory.logger(@out = "")

      @sent_msg = @mailer.deliver(@message)
    end

    should "return the message that was sent" do
      assert_same @message, @sent_msg
    end

    should "log that the message was sent" do
      assert_not_empty @out
    end

    should "build the message from the given block" do
      built_msg = @mailer.deliver do
        from    'me@example.com'
        to      'you@example.com'
        subject 'a message'
      end

      assert_kind_of Mailthis::Message, built_msg
      assert_equal ['me@example.com'], built_msg.from
      assert_equal ['you@example.com'], built_msg.to
      assert_equal 'a message', built_msg.subject
    end

    should "task a message and apply the given block" do
      built_msg = @mailer.deliver(Factory.message) do
        from 'me@example.com'
      end

      assert_kind_of Mailthis::Message, built_msg
      assert_equal ['me@example.com'], built_msg.from
      assert_equal ['you@example.com'], built_msg.to
      assert_equal 'a message', built_msg.subject
    end

  end

  class ValidationTests < UnitTests
    desc "when validating"
    setup do
      @invalid = Mailthis::Mailer.new do
        smtp_helo   Factory.string
        smtp_server Factory.string
        smtp_port   Factory.integer
        smtp_user   Factory.email
        smtp_pw     Factory.string
        smtp_auth   :plain
      end
    end
    subject{ @invalid }

    should "not complain if all settings are in place" do
      assert_valid
    end

    should "return itself when validating" do
      assert_same subject, subject.validate!
    end

    should "be invalid if missing the helo domain" do
      subject.smtp_helo = nil
      assert_invalid
    end

    should "be invalid if missing the server" do
      subject.smtp_server = nil
      assert_invalid
    end

    should "be invalid if missing the port" do
      subject.smtp_port = nil
      assert_invalid
    end

    should "be invalid if missing the user" do
      subject.smtp_user = nil
      assert_invalid
    end

    should "be invalid if missing the pw" do
      subject.smtp_pw = nil
      assert_invalid
    end

    should "be invalid if missing the auth" do
      subject.smtp_auth = nil
      assert_invalid
    end

    should "be invalid if missing the from" do
      subject.from = nil
      assert_invalid
    end

    should "be invalid if missing the logger" do
      subject.logger = nil
      assert_invalid
    end

    private

    def assert_valid
      assert_nothing_raised do
        subject.validate!
      end
    end

    def assert_invalid
      assert_raises(Mailthis::MailerError) do
        subject.validate!
      end
    end

  end

  class MailthisMailerTests < UnitTests
    desc "MailthisMailer"
    setup do
      @mailer_class = Mailthis::MailthisMailer
    end
    subject{ @mailer_class }

    should "include the Mailer mixin" do
      assert_includes Mailthis::Mailer, subject
    end

  end

  class TestMailerTests < UnitTests
    desc "TestMailer"
    setup do
      @mailer_class = Mailthis::TestMailer
    end
    subject{ @mailer_class }

    should "include the Mailer mixin" do
      assert_includes Mailthis::Mailer, subject
    end

  end

  class TestMailerInitTests < TestMailerTests
    desc "when init"
    setup do
      @message = Factory.message
      @mailer  = Factory.mailer # b/c in test mode, this is a test mailer
    end
    subject{ @mailer }

    should have_readers :delivered_messages
    should have_imeths :reset

    should "not have any delivered messages by default" do
      assert_empty subject.delivered_messages
    end

    should "add messages to its delivered messages when delivering them" do
      subject.deliver(@message)

      assert_equal 1, subject.delivered_messages.size
      assert_same @message, subject.delivered_messages.last
    end

    should "clear its delivered messages on reset" do
      subject.deliver(@message)
      assert_equal 1, subject.delivered_messages.size

      subject.reset
      assert_empty subject.delivered_messages
    end

  end

end

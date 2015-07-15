require 'assert'
require 'mailthis/mailer'

require 'mailthis/exceptions'

class Mailthis::Mailer

  class UnitTests < Assert::Context
    desc "Mailthis::Mailer"
    setup do
      @mailer = Mailthis::Mailer.new
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

  class SendMailTests < UnitTests
    desc "when sending mail"
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

      assert_kind_of ::Mail::Message, built_msg
      assert_equal ['me@example.com'], built_msg.from
      assert_equal ['you@example.com'], built_msg.to
      assert_equal 'a message', built_msg.subject
    end

    should "task a message and apply the given block" do
      built_msg = @mailer.deliver(Factory.message) do
        from 'me@example.com'
      end

      assert_kind_of ::Mail::Message, built_msg
      assert_equal ['me@example.com'], built_msg.from
      assert_equal ['you@example.com'], built_msg.to
      assert_equal 'a message', built_msg.subject
    end

  end

end

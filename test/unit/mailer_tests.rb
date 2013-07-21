require 'assert'
require 'mailthis/mailer'

require 'test/support/factory'
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
    should have_imeths :validate!, :send_mail

    should "know its smtp settings" do
      { :smtp_helo   => 'example.com',
        :smtp_server => 'smtp.example.com',
        :smtp_port   => 25,
        :smtp_user   => 'test@example.com',
        :smtp_pw     => 'secret'
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

    should "use smtp_user as the from by default" do
      assert_nil subject.from

      subject.smtp_user 'user'
      assert_equal 'user', subject.from
    end

    should "allow overriding the from" do
      subject.from 'a-user'
      assert_equal 'a-user', subject.from
    end

    should "know its logger" do
      assert_kind_of Mailthis::Mailer::NullLogger, subject.logger
    end

  end

  class ValidationTests < UnitTests
    desc "when validating"
    setup do
      @invalid = Mailthis::Mailer.new do
        smtp_helo   "example.com"
        smtp_server "smtp.example.com"
        smtp_port   25
        smtp_user   "test@example.com"
        smtp_pw     "secret"
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

      @sent_msg = @mailer.send_mail(@message)
    end

    should "return the message that was sent" do
      assert_same @message, @sent_msg
    end

    should "log that the message was sent" do
      assert_not_empty @out
    end

  end

end

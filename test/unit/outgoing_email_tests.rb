require 'assert'
require 'mailthis/outgoing_email'

require 'test/support/factory'
require 'mailthis/exceptions'

class Mailthis::OutgoingEmail

  class UnitTests < Assert::Context
    desc "Mailthis::OutgoingEmail"
    setup do
      @mailer  = Factory.mailer
      @message = Factory.message
      @email   = Mailthis::OutgoingEmail.new(@mailer, @message)
    end
    subject{ @email }

    should have_readers :mailer, :message
    should have_imeths :validate!, :deliver

    should "know its mailer and message" do
      assert_same @mailer, subject.mailer
      assert_same @message, subject.message
    end

    should "set the message's from to the mailer's from if message has no from" do
      assert_nil Factory.message.from
      assert_not_nil subject.message.from
      assert_equal [@mailer.from], subject.message.from
    end

    should "complain if delivering with an invalid mailer" do
      @mailer.smtp_server = nil
      assert_not @mailer.valid?

      assert_raises(Mailthis::MailerError) do
        subject.deliver
      end
    end

    should "complain if delivering an invalid message" do
      msg = Factory.message
      msg.to = nil

      assert_raises(Mailthis::MessageError) do
        Mailthis::OutgoingEmail.new(@mailer, msg).deliver
      end
    end

    should "log when delivering a message" do
      @mailer.logger = Factory.logger(out = "")
      assert_empty out

      subject.deliver

      assert_not_empty out
      assert_includes "Sent '#{@message.subject}'", out
      assert_includes @message.to_s, out
    end

    should "return the delivered message" do
      assert_same @message, subject.deliver
    end

  end

  class ValidationTests < UnitTests
    desc "when validating"

    should "not complain if all settings are in place" do
      assert_valid_with @message
    end

    should "complain if using an invalid message" do
      assert_invalid_with "not-a-valid-msg-obj"
    end

    should "complain if the message is missing required fields" do
      msg = Factory.message
      msg.subject = nil
      assert_invalid_with msg
    end

    should "complain if the message is not addressed to anyone" do
      msg = Factory.message

      msg.to = msg.cc = msg.bcc = nil
      assert_invalid_with msg
    end

    private

    def assert_valid_with(msg)
      assert_nothing_raised do
        Mailthis::OutgoingEmail.new(@mailer, msg).validate!
      end
    end

    def assert_invalid_with(msg)
      with_backtrace(caller) do
        assert_raises(Mailthis::MessageError) do
          Mailthis::OutgoingEmail.new(@mailer, msg).validate!
        end
      end
    end

  end

end

require 'assert'
require 'mailthis/message'

require 'mail'

class Mailthis::Message

  class UnitTests < Assert::Context
    desc "Mailthis::Message"
    setup do
      @from     = Factory.email
      @reply_to = Factory.email
      @to       = Factory.email
      @cc       = Factory.email
      @bcc      = Factory.email
      @subject  = Factory.string
      @body     = Factory.text

      @mail = ::Mail.new
      Assert.stub(::Mail, :new){ @mail }

      @message = Mailthis::Message.new
    end
    subject{ @message }

    should have_imeths :from, :reply_to, :to, :cc, :bcc, :subject, :body
    should have_imeths :from=, :reply_to=, :to=, :cc=, :bcc=, :subject=, :body=
    should have_imeths :to_s

    should "use Mail's default attrs" do
      assert_equal @mail.from,      subject.from
      assert_equal @mail.reply_to,  subject.reply_to
      assert_equal @mail.to,        subject.to
      assert_equal @mail.cc,        subject.cc
      assert_equal @mail.bcc,       subject.bcc
      assert_equal @mail.subject,   subject.subject
      assert_equal @mail.body.to_s, subject.body.to_s
    end

    should "write attrs with traditional writers" do
      subject.from     = @from
      subject.reply_to = @reply_to
      subject.to       = @to
      subject.cc       = @cc
      subject.bcc      = @bcc
      subject.subject  = @subject
      subject.body     = @body

      assert_equal [@from],     subject.from
      assert_equal [@reply_to], subject.reply_to
      assert_equal [@to],       subject.to
      assert_equal [@cc],       subject.cc
      assert_equal [@bcc],      subject.bcc
      assert_equal @subject,    subject.subject
      assert_equal @body,       subject.body.to_s
    end

    should "write attrs using DSL methods" do
      subject.from     @from
      subject.reply_to @reply_to
      subject.to       @to
      subject.cc       @cc
      subject.bcc      @bcc
      subject.subject  @subject
      subject.body     @body

      assert_equal [@from],     subject.from
      assert_equal [@reply_to], subject.reply_to
      assert_equal [@to],       subject.to
      assert_equal [@cc],       subject.cc
      assert_equal [@bcc],      subject.bcc
      assert_equal @subject,    subject.subject
      assert_equal @body,       subject.body.to_s
    end

    should "know its string representation" do
      assert_equal @mail.to_s, subject.to_s
    end

  end

end

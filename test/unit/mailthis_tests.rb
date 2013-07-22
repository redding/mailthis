require 'assert'
require 'mailthis'

require 'mailthis/mailer'
require 'mailthis/exceptions'

module Mailthis

  class UnitTests < Assert::Context
    desc "Mailthis"
    subject{ Mailthis }

    should have_imeth :mailer

    should "build a mailer with given args" do
      mailer = Mailthis.mailer do
        smtp_helo   "example.com"
        smtp_server "smtp.example.com"
        smtp_port   25
        smtp_user   "test@example.com"
        smtp_pw     "secret"
        smtp_auth   :plain
      end

      assert_kind_of Mailer, mailer
      assert_equal "example.com", mailer.smtp_helo
      assert_equal "smtp.example.com", mailer.smtp_server
      assert_equal 25, mailer.smtp_port
      assert_equal "test@example.com", mailer.smtp_user
      assert_equal "secret", mailer.smtp_pw
      assert_equal 'plain', mailer.smtp_auth
    end

    should "complain if building a mailer with missing settings" do
      assert_raises(MailerError) do
        mailer = Mailthis.mailer
      end
    end

  end

end

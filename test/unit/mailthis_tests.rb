require 'assert'
require 'mailthis'

require 'mailthis/mailer'
require 'mailthis/exceptions'

module Mailthis

  class UnitTests < Assert::Context
    desc "Mailthis"
    subject{ Mailthis }

    should have_imeths :mailer

    should "build a mailer with given args" do
      helo   = Factory.string
      server = Factory.string
      port   = Factory.integer
      user   = Factory.email
      pw     = Factory.string
      auth   = [:plain, :login].sample

      mailer = Mailthis.mailer do
        smtp_helo   helo
        smtp_server server
        smtp_port   port
        smtp_user   user
        smtp_pw     pw
        smtp_auth   auth
      end

      assert_kind_of Mailer, mailer

      assert_equal helo,      mailer.smtp_helo
      assert_equal server,    mailer.smtp_server
      assert_equal port,      mailer.smtp_port
      assert_equal user,      mailer.smtp_user
      assert_equal pw,        mailer.smtp_pw
      assert_equal auth.to_s, mailer.smtp_auth
    end

    should "complain if building a mailer with missing settings" do
      assert_raises(MailerError) do
        mailer = Mailthis.mailer
      end
    end

  end

end

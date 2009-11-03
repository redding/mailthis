require File.dirname(__FILE__) + '/../test_helper'

class MailerTest < Test::Unit::TestCase

  context "The Mailer" do
    setup do
      Mailer.configure do |config|
        config.smtp_helo_domain = "example.com"
        config.smtp_server = "smtp.example.com"
        config.smtp_port = 25
        config.smtp_username = "test@example.com"
        config.smtp_password = "secret"
        config.smtp_auth_type = :plain
        config.environment = Mailer.test
      end
    end

    should_have_class_methods *KNOWN_ENVIRONMENTS
    
    should_have_class_methods "configure", "config"
    should "be configurable" do
      assert_kind_of Mailer::Config, Mailer.config
      env = "test"
      Mailer.configure do |config|
        config.environment = env
      end
      assert_equal env, Mailer.config.environment
    end
    
    should_have_class_methods "build_tmail"
    context "when building TMail" do
      should "return TMail::Mail objects" do
        assert_kind_of TMail::Mail, Mailer.build_tmail({})
      end
      context "with a configured default from" do
        setup do
          @def_from = ["me@example.com"]
          Mailer.config.default_from = @def_from
        end
        should "default the from field" do
          assert_equal @def_from, Mailer.build_tmail({}).from
        end
      end
      should "default the date field" do
        assert_equal Time.now.day, Mailer.build_tmail({}).date.day
      end
      should "default the content type field" do
        assert_equal Mailer::DEFAULT_CONTENT_TYPE, Mailer.build_tmail({}).content_type
      end
      should "default the charset field" do
        assert_equal Mailer::DEFAULT_CHARSET, Mailer.build_tmail({}).charset
      end
      context "with the required fields" do
        setup do
          @required_settings = SIMPLE_MAIL_SETTINGS
        end
        should "work" do
          built = Mailer.build_tmail(@required_settings)
          Mailer::REQUIRED_FIELDS.each do |field|
            assert_equal @required_settings[field], built.send(field)
          end
        end
        context "and additional TMail fields" do
          setup do
            @addtl_fields = [:cc, :bcc, :reply_to, :body]
            @addtl_settings = ADDTL_MAIL_SETTINGS
          end
          should "work" do
            built = Mailer.build_tmail(@addtl_settings)
            @addtl_fields.each do |field|
              assert_equal @addtl_settings[field], built.send(field)
            end
          end
        end

      end
    end

    should_have_class_methods "send", "log_tmail"

    should_have_class_methods "deliveries", "deliver_tmail"
    should "have a deliveries cache" do
      assert_kind_of ::Array, Mailer.deliveries
    end    
    context "delivering an invalid mail" do
      setup do
        @mail = Mailer.build_tmail({})
      end
      should "fail" do
        assert_raises(Mailer::SendError) { Mailer.deliver_tmail(@mail) }
      end
    end
    context "delivering valid mail" do
      setup do
        @mail_settings = SIMPLE_MAIL_SETTINGS
        @mail = Mailer.build_tmail(@mail_settings)
      end
      context "in development" do
        setup do
          Mailer.config.environment = Mailer.development
          @out, @err = capture_std_output do 
            Mailer.deliver_tmail(@mail)
          end
        end
        should "log the mail" do
          assert @err.string.empty?
          assert_match "To: #{@mail_settings[:to]}", @out.string
          assert_match "From: #{@mail_settings[:from]}", @out.string
          assert_match "Subject: #{@mail_settings[:subject]}", @out.string
        end
      end
      context "in testing" do
        setup do
          Mailer.config.environment = Mailer.test
          Mailer.deliveries.clear
          Mailer.deliver_tmail(@mail)
        end
        should "cache the mail" do
          assert_equal 1, Mailer.deliveries.length
          sent_mail = Mailer.deliveries.latest
          assert_equal @mail_settings[:to], sent_mail.to
          assert_equal @mail_settings[:from], sent_mail.from
          assert_equal @mail_settings[:subject], sent_mail.subject
        end
        
        # Test helpers tests
        should "provide a test helper to get the latest sent mail" do
          assert_equal Mailer.deliveries.latest, latest_sent_mail
        end
        
        context "the latest sent mail" do
          setup do
            Mailer.send(COMPLEX_MAIL_SETTINGS)
          end
          subject { latest_sent_mail }

          # Shoulda macros tests
          should_be_sent_from(COMPLEX_MAIL_SETTINGS[:from])
          should_be_sent_with_reply_to(COMPLEX_MAIL_SETTINGS[:reply_to])
          should_be_sent_to(COMPLEX_MAIL_SETTINGS[:to])
          should_be_sent_cc(COMPLEX_MAIL_SETTINGS[:cc])
          should_be_sent_bcc(COMPLEX_MAIL_SETTINGS[:bcc])
          should "provide a test helper for sending mail with a specific subject" do
          end
          should "provide a test helper for sending mail with matching subject" do
          end
          should "provide a test helper for sending mail with matching body" do
          end
          should "provide a test helper for sending mail with a content type" do
          end
        end
      end
    end
    
  end

end
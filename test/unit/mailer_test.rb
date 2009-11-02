require File.dirname(__FILE__) + '/../test_helper'

class MailerTest < Test::Unit::TestCase

  context "The Mailer" do

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
          @required_settings = {
            :from => ["me@example.com"],
            :to => ["you@example.com"],
            :subject => "a message for you"
          }
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
            @addtl_settings = {
              :cc => ["cc@example.com"],
              :bcc => ["bcc@example.com"],
              :reply_to => ["i@example.com"],
              :body => "body passed as field param"
            }
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

    # TODO: build in deliveries framework and test
    should_have_class_methods "deliveries", "deliver_tmail"
    should "have a deliveries cache" do
      assert_kind_of ::Array, Mailer.deliveries
    end
    
    should_have_class_methods "send", "log_tmail"
            
  end

end
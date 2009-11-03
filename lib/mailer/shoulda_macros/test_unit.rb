module Mailer; end
module Mailer::ShouldaMacros; end

module Mailer::ShouldaMacros::TestUnit
  
  protected

  def should_be_sent_from(*addresses)
    addresses.flatten.each do |address|
      should "should be sent from #{address}" do
        assert(subject.from.include?(address), "mail not sent from #{address}")
      end
    end
  end
    
  def should_be_sent_with_reply_to(*addresses)
    addresses.flatten.each do |address|
      should "should be sent with reply to #{address}" do
        assert(subject.reply_to.include?(address), "mail not sent with reply to #{address}")
      end
    end
  end
    
  def should_be_sent_to(*addresses)
    addresses.flatten.each do |address|
      should "should be sent to #{address}" do
        assert(subject.to.include?(address), "mail not sent to #{address}")
      end
    end
  end
    
  def should_be_sent_cc(*addresses)
    addresses.flatten.each do |address|
      should "should be sent cc #{address}" do
        assert(subject.cc.include?(address), "mail not sent cc #{address}")
      end
    end
  end
    
  def should_be_sent_bcc(*addresses)
    addresses.flatten.each do |address|
      should "should be sent bcc #{address}" do
        assert(subject.bcc.include?(address), "mail not sent bcc #{address}")
      end
    end
  end
    
  def should_be_sent_with_subject(string)
    should "should be sent with the subject '#{string}'" do
      assert_equal(string, subject.subject, "mail not sent with the subject '#{string}'")
    end
  end
    
  def should_be_sent_with_subject_containing(match)
    should "should be sent with the subject containing '#{match}'" do
      assert_match(match, subject.subject, "mail not sent with the subject containing '#{match}'")
    end
  end
    
  def should_be_sent_with_body_containing(match)
    should "should be sent with the body containing '#{match}'" do
      assert_match(match, subject.body, "mail not sent with the body containing '#{match}'")
    end
  end
    
  def should_be_sent_with_content_type(string)
    should "should be sent with the content type '#{string}'" do
      assert_equal(string, subject.content_type, "mail not sent with the content type '#{string}'")
    end
  end
    
  def should_not_pass_the_config_check
    should "not pass the config check" do
      assert_raises(Mailer::ConfigError) do
        Mailer.config.check
      end
    end
  end
  
end

Test::Unit::TestCase.extend(Mailer::ShouldaMacros::TestUnit) if defined? Test::Unit::TestCase

require File.dirname(__FILE__) + '/../test_helper'

class Mailer::MailboxTest < Test::Unit::TestCase

  context "The Mailbox class" do
    should_have_instance_methods 'open', 'check', 'empty?', 'empty!'
  end

end
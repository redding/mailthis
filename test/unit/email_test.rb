require File.dirname(__FILE__) + '/../test_helper'

class Mailer::EmailTest < Test::Unit::TestCase

  context "The Mailer::Email" do

    should "inherit from TMail::Mail" do 
      assert_kind_of TMail::Mail, subject
    end
    
    should_have_instance_methods 'part_of_body'
  end

end
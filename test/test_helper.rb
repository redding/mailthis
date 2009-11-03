# http://sneaq.net/textmate-wtf
$:.reject! { |e| e.include? 'TextMate' }

require 'rubygems'
require 'test/unit'
require 'shoulda'

# gem install kelredd-useful --source http://gemcutter.org
require 'useful/shoulda_macros/test_unit'
# => for mailer tests: capture_std_output
require 'useful/ruby_extensions/object'

lib_path = File.expand_path(File.join(File.dirname(__FILE__), '..', 'lib'))
$LOAD_PATH.unshift(lib_path) unless $LOAD_PATH.include?(lib_path)
require 'mailer'

require 'mailer/test_helpers'
include Mailer::TestHelpers

require 'mailer/shoulda_macros/test_unit'

# setup for the test environment
MAILER_LOG_AS_PUTS = true
KNOWN_ENVIRONMENTS = ["development", "test", "production"]
SIMPLE_MAIL_SETTINGS = {
  :from => ["me@example.com"],
  :to => ["you@example.com"],
  :subject => "a message for you"
}
ADDTL_MAIL_SETTINGS = {
  :cc => ["cc1@example.com", "cc2@example.com"],
  :bcc => ["bcc@example.com"],
  :reply_to => ["i@example.com"],
  :body => "body passed as field param"
}
COMPLEX_MAIL_SETTINGS = SIMPLE_MAIL_SETTINGS.merge(ADDTL_MAIL_SETTINGS)

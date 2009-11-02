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
Mailer.config.environment = Mailer.test

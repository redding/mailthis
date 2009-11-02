# http://sneaq.net/textmate-wtf
$:.reject! { |e| e.include? 'TextMate' }

require 'rubygems'
require 'test/unit'
require 'shoulda'

# gem install kelredd-useful --source http://gemcutter.org
require 'useful/shoulda_macros/test_unit'

lib_path = File.expand_path(File.join(File.dirname(__FILE__), '..', 'lib'))
$LOAD_PATH.unshift(lib_path) unless $LOAD_PATH.include?(lib_path)
require 'mailer'

# TODO: setup your test environment here
KNOWN_ENVIRONMENTS = ["development", "test", "production"]
Mailer.config.environment = Mailer.test

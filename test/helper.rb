# this file is automatically required when you run `assert`
# put any test helpers here

# add the root dir to the load path
$LOAD_PATH.unshift(File.expand_path("../..", __FILE__))

# require pry for debugging (`binding.pry`)
require 'pry'

# # setup for the test environment
# MAILER_LOG_AS_PUTS = true
# KNOWN_ENVIRONMENTS = ["development", "test", "production"]
# SIMPLE_MAIL_SETTINGS = {
#   :from => ["me@example.com"],
#   :to => ["you@example.com"],
#   :subject => "a message for you"
# }
# ADDTL_MAIL_SETTINGS = {
#   :cc => ["cc1@example.com", "cc2@example.com"],
#   :bcc => ["bcc@example.com"],
#   :reply_to => ["i@example.com"],
#   :body => "body passed as field param"
# }
# COMPLEX_MAIL_SETTINGS = SIMPLE_MAIL_SETTINGS.merge(ADDTL_MAIL_SETTINGS)

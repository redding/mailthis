module Mailthis

  MailthisError = Class.new(StandardError)
  MailerError   = Class.new(MailthisError)
  SendError     = Class.new(MailthisError)

end

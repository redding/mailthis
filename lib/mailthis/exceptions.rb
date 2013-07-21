module Mailthis

  MailthisError = Class.new(StandardError)
  MailerError   = Class.new(MailthisError)
  MessageError  = Class.new(MailthisError)

end

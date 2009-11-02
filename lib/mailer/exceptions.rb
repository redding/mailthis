module Mailer

  class MailerError < StandardError
  end
  
  class ConfigError < MailerError
  end
  
  class SendError < MailerError
  end

end

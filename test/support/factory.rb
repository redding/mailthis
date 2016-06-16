require 'assert/factory'

module Factory
  extend Assert::Factory

  def self.mailer(s = {})
    s ||= {}
    require 'mailthis/mailer'
    Mailthis::Mailer.new do
      smtp_helo   (s.key?(:smtp_helo)   ? s[:smtp_helo]   : "example.com")
      smtp_server (s.key?(:smtp_server) ? s[:smtp_server] : "smtp.example.com")
      smtp_port   (s.key?(:smtp_port)   ? s[:smtp_port]   : 25)
      smtp_user   (s.key?(:smtp_user)   ? s[:smtp_user]   : "test@example.com")
      smtp_pw     (s.key?(:smtp_pw)     ? s[:smtp_pw]     : "secret")
      smtp_auth   (s.key?(:smtp_auth)   ? s[:smtp_auth]   : :plain)
      from        (s.key?(:from)        ? s[:from]        : "me@example.com")
      logger      (s.key?(:logger)      ? s[:logger]      : nil)
    end
  end

  def self.message(settings = nil)
    require 'mailthis/message'
    message = Mailthis::Message.new
    message.to      'you@example.com'
    message.subject 'a message'

    (settings || {}).inject(message) do |msg, (setting, value)|
      msg.send("#{setting}=", value)
      msg
    end
  end

  def self.logger(string_val)
    require 'logger'
    require 'stringio'
    Logger.new(StringIO.new(string_val))
  end

end


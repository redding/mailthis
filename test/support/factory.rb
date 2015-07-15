require 'assert/factory'

module Factory
  extend Assert::Factory

  def self.mailer
    require 'mailthis/mailer'
    Mailthis::Mailer.new do
      smtp_helo   "example.com"
      smtp_server "smtp.example.com"
      smtp_port   25
      smtp_user   "test@example.com"
      smtp_pw     "secret"
      smtp_auth   :plain
      from        "me@example.com"
    end
  end

  def self.message(settings = nil)
    require 'mail'
    message = Mail.new do
      to      'you@example.com'
      subject 'a message'
    end
    (settings || {}).inject(message) do |msg, (setting, value)|
      msg[setting] = value
      msg
    end
  end

  def self.logger(string_val)
    require 'logger'
    require 'stringio'
    Logger.new(StringIO.new(string_val))
  end

end


# Mailthis

## Description

Configure and send email using Mail (https://github.com/mikel/mail) over Net:SMTP.

## Usage

### A basic example

```ruby
require 'mailthis'

GMAIL = Mailthis.mailer do
  smtp_helo   "example.com"
  smtp_server "smtp.gmail.com"
  smtp_port   587
  smtp_user   "test@example.com"
  smtp_pw     'secret'
end

GMAIL.send_mail do
  subject 'a message for you'
  to      'you@example.com'
  body    'here is a message for you'
end
```

### A more complex example

```ruby
require 'mailthis'

GMAIL = Mailthis.mailer do
  smtp_helo   "example.com"
  smtp_server "smtp.gmail.com"
  smtp_port   587
  smtp_user   "test@example.com"
  smtp_pw     'secret'

  smtp_auth "plain"                     # (optional) default: "login"
  from      "me@example.com"            # (optional) default: config.smtp_username (if valid)
  logger    Logger.new("log/email.log") # (optional) default: no logger, no logging
end

msg = Mail.new
msg.from     = 'bob@example.com',       # (optional) default: mailer #from
msg.reply_to = 'bob@me.com',            # (optional) default: self #from
msg.to       = "you@example.com",
msg.cc       = "Another <another@example.com>",
msg.bcc      = ["one@example.com", "Two <two@example.com>"],
msg.subject  = "a message",
msg.body     = "a message body"

GMAIL.send_mail(msg)
```

## Installation

Add this line to your application's Gemfile:

    gem 'whysoslow'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install whysoslow

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Added some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request

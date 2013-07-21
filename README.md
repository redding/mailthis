# Mailthis

## Description

This is just a little gem to let you configure and send email using Mail over Net:SMTP.  It also lets you check email using Net::POP3.

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

GMAIL.send_mail("a message for you", :to => "you@example.com") do
  # the return value of the block is used as the email body
  "here is a message for you"
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

GMAIL.send_mail({
  :from     => 'bob@example.com',       # (optional) default: mailer #from
  :reply_to => 'bob@me.com',            # (optional) default: self #from
  :to       => "you@example.com",
  :cc       => "Another <another@example.com>",
  :bcc      => ["one@example.com", "Two <two@example.com>"],
  :subject  => "a message",
  :body     => "a message body"
})
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

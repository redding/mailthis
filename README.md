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

GMAIL.deliver do
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
  from      "me@example.com"            # (optional) default: `smtp_user` (if valid)
  logger    Logger.new("log/email.log") # (optional) default: no logger, no logging
end

msg = Mailthis::Message.new
msg.from     = 'bob@example.com',       # (optional) default: mailer #from
msg.reply_to = 'bob@me.com',            # (optional) default: self #from
msg.to       = "you@example.com",
msg.cc       = "Another <another@example.com>",
msg.bcc      = ["one@example.com", "Two <two@example.com>"],
msg.subject  = "a message",
msg.body     = "a message body"

GMAIL.deliver(msg)
```

### Disable sending mail

You can disable actually sending mail (in tests, non-production envs, etc) by setting the `MAILTHIS_DISABLE_SEND` environment variable.  For example:

```ruby
if !production?
  # disable actually delivering emails when not in production
  ENV['MAILTHIS_DISABLE_SEND'] = 'y'
end
```

Set the env var to *any not-nil* value and mailthis will not send any mail.  It will do everything else, however, including logging the mail it would have sent and "delivering" the message in test mode (see below).

### Test Mode

When testing it is often nice to be able to check and see if your code delivered email or not.  Mailthis has a test mode where the mailer tracks
the messages it delivers.  Enable this with the env var `MAILTHIS_TEST_MODE`
in your tests.

```ruby
# in your test helper or whatever
ENV['MAILTHIS_TEST_MODE'] = 'y'

# in your tests or whatever
should "email a notification" do
  assert_not_empty my_mailer.delivered_messages

  msg = my_mailer.delivered_messages.last
  exp_notification = Notification.new
  assert_equal [exp_notification.to],    msg.to
  assert_equal exp_notification.subject, msg.subject
  assert_equal exp_notification.body,    msg.body.to_s
  # or whatever your test logic may be, this is just an example
end
```

Set the env var to *any not-nil* value to enable this mode.

## Installation

Add this line to your application's Gemfile:

    gem 'mailthis'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install mailthis

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Added some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request

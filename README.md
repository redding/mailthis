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

## Testing

TODO: deal with this.

Mailer has some helpers and Shoulda macros to ease testing that emails were delivered with the correct parameters, fields, and content.

Note: This testing only tests that mail objects were built successfully and passed all checks for delivery.  This does not actually send the mails or test sending the mails at the Net::SMTP level.

### Helpers

In test_helper.rb or wherever:

    require 'mailer/test_helpers'
    include Mailer::TestHelpers

### TODO: remove this
=== Shoulda Macros

In test_helper.rb or wherever:

    require 'mailer/shoulda_macros/test_unit'

### TODO: address these then remove this
=== Notes / TODOs

It's only live testing and known to be working with SMTP servers requiring TLS (ala Gmail).  I want to extend it to support some auth configuration and switching so that it works with SMTP, SMTPS, and SMTP/TLS.

Right now, the Mailer can only have one configuration.  Maybe like to extend it to create instances of Mailers with different configurations?

I want to add helpers for downloading email with attachments and storing in memory as a string and file streams.  Maybe?

# Mailthis

## Description

This is just a little gem to let you configure and send email using Mail over Net:SMTP.  It also lets you check email using Net::POP3.

## Usage

### Sending mail: A simple configuration

```ruby
require 'mailthis'

Mailthis.configure do |config|
  config.smtp_server = "smtp.gmail.com"
  config.smtp_helo_domain = "example.com"
  config.smtp_port = 587
  config.smtp_username = "test@example.com"
  config.smtp_password = 'secret'
  config.environment = Mailer.production  # not required, default is Mailer.development
end

Mailthis.send(:to => "you@example.com", :subject => "a message for you") do
  "here is a message for you"
end
```

### Sending mail: A more complex configuration

```ruby
# Note: this is showing a more complex configuration
# only setup or configure what you need or want to

require 'mailthis'

Mailthis.configure do |config|
  config.smtp_server = "smtp.gmail.com"
  config.smtp_helo_domain = "example.com"
  config.smtp_port = 587
  config.smtp_username = "test@example.com"
  config.smtp_password = 'secret'

  config.environment = Mailthis.production  # (optional) default: Mailthis.development
  config.smtp_auth_type = "plain"           # (optional) default: "login"
  config.default_from   = "me@example.com"  # (optional) default: config.smtp_username (if valid)
  config.log_file = "log/email.log"         # (optional) default: no logging
end

# send mails with the configured mailer...
# note: only requires :from (if no config.default_from), :to, and :subject
Mailthis.send({
  :from     => 'bob@example.com',                      # (optional) default: config.default_from
  :reply_to => 'bob@me.com',                           # (optional)
  :to       => "you@example.com",
  :cc       => "Al <another@example.com>",             # send with specific naming
  :bcc      => ["one@example.com", "two@example.com"], # send to multiple addresses
  :subject  => "a message"
}) do
  # (optional) don't pass `#send` a block if you don't want your mail to have a body
  "a message body"
end
```

### TODO: remove this
=== Checking mail

    mailbox = Mailer::Mailbox.new({
      :server => "pop.server",      # set to whatever needed
      :port => 995,                 # set to whatever needed
      :email => "test@example.com", # the inbox to check
      :password => "secret"         # the email account pop password
    })

    # check if you have mail
    mailbox.empty?

    # open the mailbox, getting a Net:POP3 object
    mailbox.open do |box|
      # box is a Net::POP3 obj
      box.each_mail do |mail|
        puts mail.header
      end
    end

    # check any email in mailbox, getting a collection of Net::POPMail objects
    mailbox.check do |email|
      # email is a collection of Net::POPMail objects
      puts email.length
    end

    # download said email to files
    mailbox.check do |email|
      # nothing special here, just using Net::POP3 patterns for handling mail
      pop.mails.each_with_index do |mail, index|
        File.open( "inbox/#{index}", 'w+' ) do |file|
          file.write mail.pop
        end
        mail.delete
      end
    end

    # empty the mailbox
    mailbox.empty!

### TODO: remove this
=== File cacheing your mail

Mailer provides a file cache object to abstract caching your mail to the file system.  You configure it much like you would a mailbox and call 'get_new_mail!' to download and cache new mail to the file system.  The file cache will attempt to delete any mail it downloads from the server.

    # build and configure your file cache
    test_at_example = Mailer::FileCache.new(~/.mailer/test_at_example, {
      :server => "pop.server",      # set to whatever needed
      :port => 995,                 # set to whatever needed
      :email => "test@example.com", # the inbox to check
      :password => "secret"         # the email account pop password
    })


    # download new mail
    test_at_example.get_new_mail!


    # do stuff with the files in the cache via opened File objects
    # => the cache mixes in Enumerable, returning open File streams
    test_at_example.each do |file|
      # some code to read or do stuff with the opened File object
    end

    headers = test_at_example.collect do |file|
      # some code to parse out and return the header info to a string
    end

    # or even better, build TMail::Mail objects from the mail files
    tmails = test_at_example.collect do |file|
      TMail::Mail.parse(file.read)
    end


    # if you prefer, just get the collection of file paths, to use as you see fit
    # => 'entries' is just an array of paths to the files in the cache
    entry_file_paths = test_at_example.entries
    tmails = test_at_example.entries.collect do |path|
      TMail::Mail.load(path)
    end


    # work through the cache one at a time using the cache keys
    test_at_example.keys.each do |key|
      test_at_example.read(key) do |file|
        # do something with the open file stream
      end
      test_at_example.delete(key)
    end

    # or yet even better, get Mailer::Email object (which are just special TMail::Mail objects)
    emails = test_at_example.emails
    email = test_at_example.email(test_at_example.keys.first)


    # test if the cache has any entries
    test_at_example.empty?    # => false

    # delete entries one at a time
    test_at_example.delete(path_or_key)

    # clear out the entire cache in one fell swoop
    test_at_example.clear!
    test_at_example.empty?    # => true

## Testing

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

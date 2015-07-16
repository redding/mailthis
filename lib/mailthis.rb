require 'mailthis/version'
require 'mailthis/exceptions'
require 'mailthis/message'
require 'mailthis/mailer'

module Mailthis

  def self.mailer(*args, &block)
    Mailer.new(*args, &block).validate!
  end

end

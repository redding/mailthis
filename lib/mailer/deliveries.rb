require 'mailer/exceptions'

# This is just an array of sent tmail Mail objs that Mailer puts sent mails into in test mode
module Mailer
  class Deliveries < ::Array

    def initialize(*args)
      super(args)
    end
        
  end
end

require 'mailer/exceptions'
require 'tmail'

module Mailer

  # this class inherits from TMail::Mail and just adds some niceties to it
  class Email < TMail::Mail
  
    # a way to return just a part of a multipart body, if it is multipart
    def part_of_body(part_content_type)
      if multipart? && (part = parts.select{|part| part.content_type == part_content_type}.try(:first))
        part.body
      else
        body
      end
    end

  end
  
end
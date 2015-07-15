require 'mail'

module Mailthis

  class Message

    def initialize
      @mail = ::Mail.new
    end

    def from(*args);     @mail.from(*args);     end
    def reply_to(*args); @mail.reply_to(*args); end
    def to(*args);       @mail.to(*args);       end
    def cc(*args);       @mail.cc(*args);       end
    def bcc(*args);      @mail.bcc(*args);      end
    def subject(*args);  @mail.subject(*args);  end
    def body(*args);     @mail.body(*args);     end

    def from=(value);     @mail.from     = value; end
    def reply_to=(value); @mail.reply_to = value; end
    def to=(value);       @mail.to       = value; end
    def cc=(value);       @mail.cc       = value; end
    def bcc=(value);      @mail.bcc      = value; end
    def subject=(value);  @mail.subject  = value; end
    def body=(value);     @mail.body     = value; end

    def to_s
      @mail.to_s
    end

  end

end

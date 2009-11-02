module Mailer; end

module Mailer::TestHelpers
  
  def latest_sent_mail
    Mailer.deliveries.latest
  end
  
end

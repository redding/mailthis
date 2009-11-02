module Mailer; end
module Mailer::ShouldaMacros; end

module Mailer::ShouldaMacros::TestUnit
  
  protected
  
end

Test::Unit::TestCase.extend(Mailer::ShouldaMacros::TestUnit) if defined? Test::Unit::TestCase

# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = %q{kelredd-mailer}
  s.version = "0.1.5"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["Kelly Redding"]
  s.date = %q{2010-04-01}
  s.email = %q{kelly@kelredd.com}
  s.extra_rdoc_files = ["README.rdoc"]
  s.files = ["README.rdoc", "Rakefile", "lib/mailer", "lib/mailer/config.rb", "lib/mailer/deliveries.rb", "lib/mailer/email.rb", "lib/mailer/exceptions.rb", "lib/mailer/file_cache.rb", "lib/mailer/mailbox.rb", "lib/mailer/shoulda_macros", "lib/mailer/shoulda_macros/test_unit.rb", "lib/mailer/ssl", "lib/mailer/ssl/pop.rb", "lib/mailer/ssl/tls.rb", "lib/mailer/test_helpers.rb", "lib/mailer/version.rb", "lib/mailer.rb"]
  s.homepage = %q{http://github.com/kelredd/mailer}
  s.rdoc_options = ["--main", "README.rdoc"]
  s.require_paths = ["lib"]
  s.rubygems_version = %q{1.3.6}
  s.summary = %q{This gem is just a simple mailer interface.}

  if s.respond_to? :specification_version then
    current_version = Gem::Specification::CURRENT_SPECIFICATION_VERSION
    s.specification_version = 3

    if Gem::Version.new(Gem::RubyGemsVersion) >= Gem::Version.new('1.2.0') then
      s.add_runtime_dependency(%q<log4r>, [">= 0"])
      s.add_runtime_dependency(%q<tmail>, [">= 1.2.3.0"])
      s.add_runtime_dependency(%q<kelredd-useful>, [">= 0.2.0"])
      s.add_development_dependency(%q<shoulda>, [">= 2.10.2"])
    else
      s.add_dependency(%q<log4r>, [">= 0"])
      s.add_dependency(%q<tmail>, [">= 1.2.3.0"])
      s.add_dependency(%q<kelredd-useful>, [">= 0.2.0"])
      s.add_dependency(%q<shoulda>, [">= 2.10.2"])
    end
  else
    s.add_dependency(%q<log4r>, [">= 0"])
    s.add_dependency(%q<tmail>, [">= 1.2.3.0"])
    s.add_dependency(%q<kelredd-useful>, [">= 0.2.0"])
    s.add_dependency(%q<shoulda>, [">= 2.10.2"])
  end
end

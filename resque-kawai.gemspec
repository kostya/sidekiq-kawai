# -*- encoding: utf-8 -*-
require File.dirname(__FILE__) + "/lib/version"

Gem::Specification.new do |s|
  s.name = %q{resque-kawai}
  s.version = Rq::VERSION

  s.authors = ["Makarchev Konstantin"]
  s.autorequire = %q{resque-kawai.rb}
  
  s.description = %q{Syntax sugar for Resque consumers. Each consumer is a class, with clean interface, and custom logger.}
  s.summary = %q{Syntax sugar for Resque consumers. Each consumer is a class, with clean interface, and custom logger.}

  s.email = %q{kostya27@gmail.com}
  s.homepage = %q{http://github.com/kostya/resque-kawai}

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]

  s.add_dependency 'activesupport'
  s.add_dependency 'resque'
  s.add_development_dependency "rspec"
  
end

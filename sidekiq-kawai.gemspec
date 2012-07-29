# -*- encoding: utf-8 -*-
require File.dirname(__FILE__) + "/lib/version"

Gem::Specification.new do |s|
  s.name = %q{sidekiq-kawai}
  s.version = Sk::VERSION

  s.authors = ["Makarchev Konstantin", "Damir Sharipov"]

  s.description = %q{Syntax sugar for Sidekiq workers. Each consumer is a class, with clean interface, and custom logger. Usefull when count of different events ~100 and more.}
  s.summary = %q{Syntax sugar for Sidekiq consumers. Each consumer is a class, with clean interface, and custom logger. Usefull when count of different events ~100 and more.}
  s.email = %q{dammer2k@gmail.com}
  s.homepage = %q{https://github.com/dammer/sidekiq-kawai}

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]

  s.add_dependency 'activesupport'
  s.add_dependency 'sidekiq', '>= 2.1.0'
  s.add_development_dependency "rspec"
  s.add_development_dependency "rake"

end
